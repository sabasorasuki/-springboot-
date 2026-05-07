import argparse
import hashlib
import json
import math
import os
import random
from collections import defaultdict
from datetime import datetime
from pathlib import Path


DOMAINS = ["huagao", "zuopin", "project", "artist"]
SOURCE_REAL = "real"
SOURCE_SYNTHETIC = "synthetic"
SOURCE_MIXED = "mixed"
SYN_PREFIX = "syn_"
ACTION_WEIGHTS = {
    "impression": 0,
    "click_detail": 1,
    "detail_view": 1,
    "detail_dwell": 1,
    "favorite": 2,
    "like": 2,
    "comment": 2,
    "follow": 2,
    "add_to_cart": 3,
    "apply_project": 3,
    "create_order": 4,
}

pymysql = None
np = None
XGBRanker = None


def load_runtime_dependencies():
    global pymysql, np, XGBRanker
    try:
        import pymysql as pymysql_module
        import numpy as numpy_module
    except ImportError as exc:
        requirements = Path(__file__).resolve().with_name("requirements.txt")
        raise SystemExit(
            "Missing Python dependency: %s. Install with: pip install -r %s"
            % (exc.name, requirements)
        ) from exc
    pymysql = pymysql_module
    np = numpy_module
    try:
        from xgboost import XGBRanker as xgb_ranker
        XGBRanker = xgb_ranker
    except ImportError:
        XGBRanker = None


def db_config():
    return {
        "host": os.getenv("ARTISTSION_DB_HOST") or os.getenv("DB_HOST") or "127.0.0.1",
        "port": int(os.getenv("ARTISTSION_DB_PORT") or os.getenv("DB_PORT") or "3306"),
        "database": os.getenv("ARTISTSION_DB_NAME") or os.getenv("DB_NAME") or "artistsion",
        "user": os.getenv("ARTISTSION_DB_USER") or os.getenv("DB_USERNAME") or "root",
        "password": os.getenv("ARTISTSION_DB_PASS") or os.getenv("DB_PASSWORD") or "",
        "charset": "utf8mb4",
        "autocommit": False,
        "cursorclass": pymysql.cursors.DictCursor,
    }


def connect():
    return pymysql.connect(**db_config())


def repo_root():
    return Path(__file__).resolve().parents[2]


def execute_sql_file(conn, path):
    text = Path(path).read_text(encoding="utf-8")
    statements = []
    current = []
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("--"):
            continue
        current.append(line)
        if stripped.endswith(";"):
            statements.append("\n".join(current).rstrip(";"))
            current = []
    if current:
        statements.append("\n".join(current))
    with conn.cursor() as cur:
        for statement in statements:
            cur.execute(statement)
    conn.commit()


def ensure_tables(conn):
    ddl = repo_root() / "artistsion-admin" / "sql" / "2026-05-07-site-recs-schema.sql"
    execute_sql_file(conn, ddl)


def table_exists(conn, table_name):
    with conn.cursor() as cur:
        cur.execute("SHOW TABLES LIKE %s", (table_name,))
        return cur.fetchone() is not None


def source_clause(source, request_col="request_id", event_col="event_id"):
    if source == SOURCE_SYNTHETIC:
        return "(%s LIKE '%s%%' OR %s LIKE '%s%%')" % (request_col, SYN_PREFIX, event_col, SYN_PREFIX)
    if source == SOURCE_REAL:
        return "(COALESCE(%s, '') NOT LIKE '%s%%' AND COALESCE(%s, '') NOT LIKE '%s%%')" % (
            request_col,
            SYN_PREFIX,
            event_col,
            SYN_PREFIX,
        )
    return "1 = 1"


def backfill_legacy_huagao(conn, source):
    if not table_exists(conn, "rec_huagao_request_log"):
        return {"huagaoRequest": 0, "huagaoImpression": 0, "huagaoAction": 0}
    req_where = "request_id LIKE %s" if source == SOURCE_SYNTHETIC else "request_id NOT LIKE %s"
    req_params = (SYN_PREFIX + "%",)
    if source == SOURCE_MIXED:
        req_where = "1 = 1"
        req_params = ()
    with conn.cursor() as cur:
        request_count = cur.execute(
            """
            INSERT IGNORE INTO rec_request_log (
                request_id, domain, query_key, scene, user_id, visitor_id, session_id,
                keyword, category, tag_id, page_no, page_size, sort_mode,
                result_total, returned_count, fallback, model_version, created_at
            )
            SELECT request_id, 'huagao', query_key, scene, user_id, visitor_id, session_id,
                   keyword, fenlei, tag_id, page_no, page_size, sort_mode,
                   result_total, returned_count, 0, NULL, created_at
            FROM rec_huagao_request_log
            WHERE """ + req_where,
            req_params,
        )
        impression_count = cur.execute(
            """
            INSERT IGNORE INTO rec_impression_log (
                request_id, domain, item_id, author_id, position, page_no, page_size,
                scene, model_version, created_at
            )
            SELECT request_id, 'huagao', huagao_id, shangjia_id, position, page_no, page_size,
                   scene, NULL, created_at
            FROM rec_huagao_impression_log
            WHERE """ + req_where,
            req_params,
        )
        action_where = source_clause(source)
        action_count = cur.execute(
            """
            INSERT IGNORE INTO rec_action_log (
                event_id, event_type, domain, request_id, item_id, author_id, user_id,
                visitor_id, session_id, position, event_value, scene, source,
                model_version, created_at
            )
            SELECT event_id, event_type, 'huagao', request_id, huagao_id, shangjia_id, user_id,
                   visitor_id, session_id, position, event_value, scene, source,
                   NULL, created_at
            FROM rec_huagao_action_log
            WHERE """ + action_where
        )
    conn.commit()
    return {
        "huagaoRequest": request_count,
        "huagaoImpression": impression_count,
        "huagaoAction": action_count,
    }


def backfill_business_actions(conn):
    counts = {}
    with conn.cursor() as cur:
        if table_exists(conn, "sys_shoucang"):
            counts["favorite"] = cur.execute(
                """
                INSERT IGNORE INTO rec_action_log (
                    event_id, event_type, domain, item_id, author_id, user_id,
                    scene, source, created_at
                )
                SELECT CONCAT('legacy_favorite_', id), 'favorite',
                       CASE
                         WHEN fenlei = '企划' THEN 'project'
                         WHEN COALESCE(price, '') <> '' AND CAST(price AS DECIMAL(18, 2)) > 0 THEN 'huagao'
                         ELSE 'zuopin'
                       END,
                       CAST(wzids AS UNSIGNED), NULL, CAST(userids AS UNSIGNED),
                       'legacy', 'legacy_sys_shoucang', NOW()
                FROM sys_shoucang
                WHERE wzids REGEXP '^[0-9]+$'
                  AND userids REGEXP '^[0-9]+$'
                """
            )
        if table_exists(conn, "sys_dianzan"):
            counts["like"] = cur.execute(
                """
                INSERT IGNORE INTO rec_action_log (
                    event_id, event_type, domain, item_id, user_id, scene, source, created_at
                )
                SELECT CONCAT('legacy_like_', id), 'like', 'zuopin',
                       CAST(zpids AS UNSIGNED), CAST(userids AS UNSIGNED),
                       'legacy', 'legacy_sys_dianzan', NOW()
                FROM sys_dianzan
                WHERE zpids REGEXP '^[0-9]+$'
                  AND userids REGEXP '^[0-9]+$'
                """
            )
        if table_exists(conn, "sys_pinglun"):
            counts["comment"] = cur.execute(
                """
                INSERT IGNORE INTO rec_action_log (
                    event_id, event_type, domain, item_id, scene, source, created_at
                )
                SELECT CONCAT('legacy_comment_', id), 'comment', 'zuopin',
                       CAST(wzids AS UNSIGNED), 'legacy', 'legacy_sys_pinglun',
                       COALESCE(pldate, NOW())
                FROM sys_pinglun
                WHERE wzids REGEXP '^[0-9]+$'
                """
            )
        if table_exists(conn, "sys_follow"):
            counts["follow"] = cur.execute(
                """
                INSERT IGNORE INTO rec_action_log (
                    event_id, event_type, domain, item_id, author_id, user_id,
                    scene, source, created_at
                )
                SELECT CONCAT('legacy_follow_', id), 'follow', 'artist',
                       following_id, following_id, follower_id,
                       'legacy', 'legacy_sys_follow', COALESCE(created_at, NOW())
                FROM sys_follow
                """
            )
        if table_exists(conn, "sys_order"):
            counts["order"] = cur.execute(
                """
                INSERT IGNORE INTO rec_action_log (
                    event_id, event_type, domain, item_id, author_id, user_id,
                    scene, source, created_at
                )
                SELECT CONCAT('legacy_order_', id), 'create_order', 'huagao',
                       CAST(spids AS UNSIGNED), CAST(shangjiaids AS UNSIGNED), CAST(userids AS UNSIGNED),
                       'legacy', 'legacy_sys_order', COALESCE(xddate, NOW())
                FROM sys_order
                WHERE spids REGEXP '^[0-9]+$'
                  AND userids REGEXP '^[0-9]+$'
                """
            )
        if table_exists(conn, "sys_project_application"):
            counts["applyProject"] = cur.execute(
                """
                INSERT IGNORE INTO rec_action_log (
                    event_id, event_type, domain, item_id, user_id,
                    scene, source, created_at
                )
                SELECT CONCAT('legacy_project_apply_', id), 'apply_project', 'project',
                       project_id, applicant_id, 'legacy', 'legacy_sys_project_application',
                       COALESCE(created_at, NOW())
                FROM sys_project_application
                """
            )
    conn.commit()
    return counts


def fetch_all(conn, sql, params=None):
    with conn.cursor() as cur:
        cur.execute(sql, params or ())
        return cur.fetchall()


def load_items(conn, domains):
    items = {domain: [] for domain in domains}
    if "huagao" in domains:
        items["huagao"] = fetch_all(
            conn,
            """
            SELECT 'huagao' AS domain, id AS item_id, name AS title, fenlei AS category,
                   CAST(shangjiaids AS UNSIGNED) AS author_id, price AS price,
                   id AS freshness_id
            FROM sys_huagao
            WHERE status = '审核成功' AND type = '上架'
            ORDER BY id
            """,
        )
    if "zuopin" in domains:
        items["zuopin"] = fetch_all(
            conn,
            """
            SELECT 'zuopin' AS domain, id AS item_id, title, fenlei AS category,
                   CAST(userids AS UNSIGNED) AS author_id, 0 AS price,
                   id AS freshness_id
            FROM sys_zuopin
            ORDER BY id
            """,
        )
    if "project" in domains:
        items["project"] = fetch_all(
            conn,
            """
            SELECT 'project' AS domain, id AS item_id, title, category,
                   user_id AS author_id, COALESCE(budget_max, budget_min, 0) AS price,
                   id AS freshness_id, style, status
            FROM sys_project
            WHERE status = '招募中'
            ORDER BY id
            """,
        )
    if "artist" in domains:
        items["artist"] = fetch_all(
            conn,
            """
            SELECT 'artist' AS domain, u.id AS item_id,
                   COALESCE(u.name, u.username) AS title,
                   u.style_tags AS category,
                   u.id AS author_id, 0 AS price,
                   u.id AS freshness_id
            FROM x_user u
            INNER JOIN x_user_role ur ON ur.user_id = u.id
            INNER JOIN x_role r ON r.role_id = ur.role_id
            WHERE u.status = 1
              AND COALESCE(u.deleted, 0) = 0
              AND r.role_name = '画师角色'
            ORDER BY u.id
            """,
        )
    return items


def load_actions(conn, domains, source):
    domain_placeholders = ",".join(["%s"] * len(domains))
    where = "domain IN (%s)" % domain_placeholders
    params = list(domains)
    if source == SOURCE_REAL:
        where += " AND COALESCE(event_id, '') NOT LIKE %s AND COALESCE(request_id, '') NOT LIKE %s"
        params.extend([SYN_PREFIX + "%", SYN_PREFIX + "%"])
    elif source == SOURCE_SYNTHETIC:
        where += " AND (COALESCE(event_id, '') LIKE %s OR COALESCE(request_id, '') LIKE %s)"
        params.extend([SYN_PREFIX + "%", SYN_PREFIX + "%"])
    return fetch_all(
        conn,
        """
        SELECT domain, event_type, item_id, author_id, user_id, visitor_id, event_value, created_at
        FROM rec_action_log
        WHERE """ + where,
        params,
    )


def load_known_actor_keys(conn, domains, source):
    domain_placeholders = ",".join(["%s"] * len(domains))
    params = list(domains)
    request_where = "domain IN (%s)" % domain_placeholders
    action_where = "domain IN (%s)" % domain_placeholders
    if source == SOURCE_REAL:
        request_where += " AND request_id NOT LIKE %s"
        action_where += " AND COALESCE(event_id, '') NOT LIKE %s AND COALESCE(request_id, '') NOT LIKE %s"
        request_params = params + [SYN_PREFIX + "%"]
        action_params = params + [SYN_PREFIX + "%", SYN_PREFIX + "%"]
    elif source == SOURCE_SYNTHETIC:
        request_where += " AND request_id LIKE %s"
        action_where += " AND (COALESCE(event_id, '') LIKE %s OR COALESCE(request_id, '') LIKE %s)"
        request_params = params + [SYN_PREFIX + "%"]
        action_params = params + [SYN_PREFIX + "%", SYN_PREFIX + "%"]
    else:
        request_params = params
        action_params = params

    keys = set(["global"])
    for row in fetch_all(
        conn,
        "SELECT DISTINCT user_id, visitor_id FROM rec_request_log WHERE " + request_where,
        request_params,
    ):
        key = actor_key(row)
        if key:
            keys.add(key)
    for row in fetch_all(
        conn,
        "SELECT DISTINCT user_id, visitor_id FROM rec_action_log WHERE " + action_where,
        action_params,
    ):
        key = actor_key(row)
        if key:
            keys.add(key)
    return keys


def actor_key(row):
    if row.get("user_id"):
        return "u:%s" % row.get("user_id")
    if row.get("visitor_id"):
        return "v:%s" % row.get("visitor_id")
    return None


def stable_jitter(*parts):
    raw = "|".join("" if part is None else str(part) for part in parts)
    digest = hashlib.md5(raw.encode("utf-8")).hexdigest()[:8]
    return int(digest, 16) / float(0xFFFFFFFF)


def build_profiles(actions, items_by_domain):
    item_lookup = {}
    for domain, rows in items_by_domain.items():
        for item in rows:
            item_lookup[(domain, int(item["item_id"]))] = item

    profiles = defaultdict(lambda: {
        "domain": defaultdict(float),
        "category": defaultdict(float),
        "author": defaultdict(float),
        "item": defaultdict(float),
    })
    popularity = defaultdict(float)
    positive_counts = defaultdict(int)

    for row in actions:
        domain = row.get("domain")
        item_id = int(row.get("item_id") or 0)
        event_type = row.get("event_type")
        weight = ACTION_WEIGHTS.get(event_type, 0)
        item = item_lookup.get((domain, item_id), {})
        pop_weight = max(weight, 0.1 if event_type == "impression" else 0)
        popularity[(domain, item_id)] += pop_weight
        if weight > 0:
            positive_counts[domain] += 1
        for key in [actor_key(row), "global"]:
            if not key or weight <= 0:
                continue
            profiles[key]["domain"][domain] += weight
            category = item.get("category")
            if category:
                for part in split_tags(category):
                    profiles[key]["category"][part] += weight
            author = row.get("author_id") or item.get("author_id")
            if author:
                profiles[key]["author"][str(author)] += weight
            profiles[key]["item"]["%s:%s" % (domain, item_id)] += weight

    if "global" not in profiles:
        profiles["global"]
    return profiles, popularity, positive_counts


def split_tags(value):
    if value is None:
        return []
    text = str(value).replace("，", ",").replace("、", ",").replace("/", ",")
    return [part.strip() for part in text.split(",") if part.strip()]


def normalize_counter(counter, top_n=20):
    rows = sorted(counter.items(), key=lambda item: item[1], reverse=True)[:top_n]
    total = sum(value for _, value in rows) or 1.0
    return [{"key": key, "weight": round(value / total, 6)} for key, value in rows]


def write_profiles(conn, profiles):
    with conn.cursor() as cur:
        for key, profile in profiles.items():
            payload = {
                "domains": normalize_counter(profile["domain"]),
                "categories": normalize_counter(profile["category"]),
                "authors": normalize_counter(profile["author"]),
                "items": normalize_counter(profile["item"]),
            }
            summary = "; ".join(
                "%s:%s" % (section, ",".join(item["key"] for item in payload[section][:3]))
                for section in ["domains", "categories", "authors"]
                if payload[section]
            )
            cur.execute(
                """
                INSERT INTO rec_actor_profile (actor_key, profile_json, summary, updated_at)
                VALUES (%s, %s, %s, NOW())
                ON DUPLICATE KEY UPDATE
                  profile_json = VALUES(profile_json),
                  summary = VALUES(summary),
                  updated_at = NOW()
                """,
                (key, json.dumps(payload, ensure_ascii=False), summary[:512]),
            )
    conn.commit()


def max_popularity(popularity, domain):
    values = [value for (pop_domain, _), value in popularity.items() if pop_domain == domain]
    return max(values) if values else 1.0


def counter_value(profile, section, key):
    if not key:
        return 0.0
    return float(profile[section].get(str(key), 0.0))


def profile_match_score(profile, item):
    score = counter_value(profile, "domain", item.get("domain")) * 0.12
    for category in split_tags(item.get("category")):
        score += counter_value(profile, "category", category) * 0.18
    if item.get("author_id"):
        score += counter_value(profile, "author", item.get("author_id")) * 0.1
    return score


def freshness_score(item, domain_items):
    if not domain_items:
        return 0.0
    max_id = max(int(row.get("freshness_id") or row.get("item_id") or 0) for row in domain_items) or 1
    current = int(item.get("freshness_id") or item.get("item_id") or 0)
    return current / float(max_id)


def baseline_score(actor, item, domain_items, profiles, popularity):
    profile = profiles[actor]
    domain = item["domain"]
    item_id = int(item["item_id"])
    pop = popularity.get((domain, item_id), 0.0) / max_popularity(popularity, domain)
    score = 0.44 * profile_match_score(profile, item)
    score += 0.26 * pop
    score += 0.18 * freshness_score(item, domain_items)
    score += 0.04 * stable_jitter(actor, domain, item_id)
    if domain == "project" and item.get("status") == "招募中":
        score += 0.08
    return score


def build_huagao_training_rows(conn, source, profiles, popularity):
    where = "i.domain = 'huagao'"
    params = []
    if source == SOURCE_REAL:
        where += " AND i.request_id NOT LIKE %s"
        params.append(SYN_PREFIX + "%")
    elif source == SOURCE_SYNTHETIC:
        where += " AND i.request_id LIKE %s"
        params.append(SYN_PREFIX + "%")
    rows = fetch_all(
        conn,
        """
        SELECT i.request_id, i.item_id, i.author_id, i.position, r.user_id, r.visitor_id,
               h.price, h.fenlei AS category, h.id AS freshness_id,
               MAX(CASE
                   WHEN a.event_type = 'create_order' THEN 4
                   WHEN a.event_type = 'add_to_cart' THEN 3
                   WHEN a.event_type IN ('favorite', 'like', 'comment', 'follow') THEN 2
                   WHEN a.event_type IN ('click_detail', 'detail_view', 'detail_dwell') THEN 1
                   ELSE 0
               END) AS label
        FROM rec_impression_log i
        INNER JOIN rec_request_log r ON r.request_id = i.request_id
        INNER JOIN sys_huagao h ON h.id = i.item_id
        LEFT JOIN rec_action_log a ON a.request_id = i.request_id
            AND a.domain = i.domain
            AND a.item_id = i.item_id
        WHERE """ + where + """
          AND h.status = '审核成功'
          AND h.type = '上架'
        GROUP BY i.request_id, i.item_id, i.author_id, i.position, r.user_id,
                 r.visitor_id, h.price, h.fenlei, h.id
        ORDER BY i.request_id, i.position
        """,
        params,
    )
    training = []
    for row in rows:
        key = actor_key(row) or "global"
        item = {
            "domain": "huagao",
            "item_id": row["item_id"],
            "author_id": row.get("author_id"),
            "category": row.get("category"),
            "price": row.get("price") or 0,
            "freshness_id": row.get("freshness_id"),
        }
        training.append({
            "request_id": row["request_id"],
            "actor_key": key,
            "item_id": int(row["item_id"]),
            "label": int(row.get("label") or 0),
            "features": huagao_features(key, item, [], profiles, popularity, row.get("position")),
        })
    return training


def huagao_features(actor, item, domain_items, profiles, popularity, position=None):
    price = float(item.get("price") or 0)
    pop = popularity.get(("huagao", int(item["item_id"])), 0.0) / max_popularity(popularity, "huagao")
    return [
        1.0 / float(position or 50),
        math.log1p(price) / 10.0,
        pop,
        profile_match_score(profiles[actor], item),
        freshness_score(item, domain_items) if domain_items else 0.0,
        stable_jitter(actor, "huagao", item["item_id"]),
    ]


def dcg(labels):
    return sum((pow(2, label) - 1) / math.log2(idx + 2) for idx, label in enumerate(labels))


def ndcg_at(labels, predictions, k):
    ranked = [label for _, label in sorted(zip(predictions, labels), reverse=True)[:k]]
    ideal = sorted(labels, reverse=True)[:k]
    ideal_dcg = dcg(ideal)
    if ideal_dcg == 0:
        return 0.0
    return dcg(ranked) / ideal_dcg


def map_at(labels, predictions, k):
    ranked = [label for _, label in sorted(zip(predictions, labels), reverse=True)[:k]]
    hits = 0
    score = 0.0
    for idx, label in enumerate(ranked, start=1):
        if label > 0:
            hits += 1
            score += hits / float(idx)
    positives = min(sum(1 for label in labels if label > 0), k)
    return score / float(positives or 1)


def train_huagao_ranker(conn, args, profiles, popularity, items):
    training = build_huagao_training_rows(conn, args.source, profiles, popularity)
    labels = [row["label"] for row in training]
    request_ids = [row["request_id"] for row in training]
    groups = []
    last_request = None
    count = 0
    for request_id in request_ids:
        if last_request is None:
            last_request = request_id
        if request_id != last_request:
            groups.append(count)
            last_request = request_id
            count = 0
        count += 1
    if count:
        groups.append(count)

    metrics = {
        "ranker": "baseline",
        "fallbackRanker": True,
        "sampleCount": len(training),
        "positiveSampleCount": sum(1 for label in labels if label > 0),
        "labelLevelCount": len(set(labels)),
        "groupCount": len(groups),
    }
    if XGBRanker is None or len(training) < 20 or metrics["positiveSampleCount"] < 3 or metrics["labelLevelCount"] < 2 or len(groups) < 2:
        return None, metrics

    x = np.array([row["features"] for row in training], dtype=float)
    y = np.array(labels, dtype=float)
    model = XGBRanker(
        objective="rank:ndcg",
        n_estimators=60,
        learning_rate=0.08,
        max_depth=4,
        subsample=0.9,
        colsample_bytree=0.9,
        random_state=42,
    )
    model.fit(x, y, group=np.array(groups, dtype=int), verbose=False)
    predictions = model.predict(x)
    metrics.update({
        "ranker": "xgboost_ltr",
        "fallbackRanker": False,
        "ndcg@5": round(ndcg_at(labels, predictions, 5), 6),
        "ndcg@10": round(ndcg_at(labels, predictions, 10), 6),
        "map@10": round(map_at(labels, predictions, 10), 6),
    })
    return model, metrics


def generate_recommendations(conn, args, domains, profiles, popularity, positive_counts, items_by_domain):
    run_ts = datetime.now().strftime("%Y%m%d%H%M%S")
    actor_keys = sorted(profiles.keys())
    if "global" not in actor_keys:
        actor_keys.append("global")

    huagao_model = None
    huagao_metrics = None
    if "huagao" in domains:
        huagao_model, huagao_metrics = train_huagao_ranker(
            conn, args, profiles, popularity, items_by_domain.get("huagao", [])
        )

    outputs = {}
    artifact_dir = Path(args.artifacts_dir)
    artifact_dir.mkdir(parents=True, exist_ok=True)
    for domain in domains:
        domain_items = items_by_domain.get(domain, [])
        metrics = {
            "ranker": "baseline",
            "fallbackRanker": True,
            "sampleCount": 0,
            "positiveSampleCount": positive_counts.get(domain, 0),
            "actorCount": len(actor_keys),
            "itemCount": len(domain_items),
        }
        if domain == "huagao" and huagao_metrics is not None:
            metrics.update(huagao_metrics)

        model_version = "site_%s_%s_%s" % (args.source, run_ts, domain)
        rec_rows = []
        for actor in actor_keys:
            scored = []
            for item in domain_items:
                if domain == "huagao" and huagao_model is not None:
                    features = huagao_features(actor, item, domain_items, profiles, popularity)
                    score = float(huagao_model.predict(np.array([features], dtype=float))[0])
                else:
                    score = baseline_score(actor, item, domain_items, profiles, popularity)
                scored.append((score, int(item["item_id"])))
            scored.sort(key=lambda row: row[0], reverse=True)
            for rank, (score, item_id) in enumerate(scored[:args.top_k], start=1):
                rec_rows.append({
                    "model_version": model_version,
                    "domain": domain,
                    "actor_key": actor,
                    "item_id": item_id,
                    "rank_no": rank,
                    "score": score,
                    "reason": metrics["ranker"],
                })

        metrics_path = artifact_dir / ("%s.metrics.json" % model_version)
        metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8")
        outputs[domain] = {
            "modelVersion": model_version,
            "metrics": metrics,
            "metricsPath": str(metrics_path),
            "recommendations": rec_rows,
        }
    return outputs


def activate_outputs(conn, outputs, source):
    with conn.cursor() as cur:
        for domain, output in outputs.items():
            model_version = output["modelVersion"]
            metrics = output["metrics"]
            cur.execute(
                "UPDATE rec_model_version SET status = 'archived' WHERE domain = %s AND status = 'active'",
                (domain,),
            )
            cur.execute(
                """
                INSERT INTO rec_model_version (
                    model_version, domain, algorithm, train_source, model_path, metrics_json,
                    sample_count, positive_sample_count, actor_count, item_count, status,
                    created_at, trained_at, activated_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'active', NOW(), NOW(), NOW())
                """,
                (
                    model_version,
                    domain,
                    metrics.get("ranker") or "baseline",
                    source,
                    output["metricsPath"],
                    json.dumps(metrics, ensure_ascii=False),
                    metrics.get("sampleCount", 0),
                    metrics.get("positiveSampleCount", 0),
                    metrics.get("actorCount", 0),
                    metrics.get("itemCount", 0),
                ),
            )
            rows = output["recommendations"]
            if rows:
                cur.executemany(
                    """
                    INSERT INTO rec_user_recommendation (
                        model_version, domain, actor_key, item_id, rank_no, score, reason, generated_at
                    )
                    VALUES (%(model_version)s, %(domain)s, %(actor_key)s, %(item_id)s,
                            %(rank_no)s, %(score)s, %(reason)s, NOW())
                    """,
                    rows,
                )
    conn.commit()


def parse_domains(value):
    domains = []
    for domain in (value or "").split(","):
        domain = domain.strip()
        if domain and domain in DOMAINS and domain not in domains:
            domains.append(domain)
    return domains or list(DOMAINS)


def main():
    parser = argparse.ArgumentParser(description="Run site-wide recommendation pipeline.")
    parser.add_argument("--domains", default=",".join(DOMAINS))
    parser.add_argument("--source", choices=[SOURCE_REAL, SOURCE_SYNTHETIC, SOURCE_MIXED], default=SOURCE_REAL)
    parser.add_argument("--top-k", type=int, default=50)
    parser.add_argument("--artifacts-dir", default=str(repo_root() / "recsys" / "site_recs" / "artifacts"))
    args = parser.parse_args()
    args.top_k = max(1, min(args.top_k, 200))
    domains = parse_domains(args.domains)

    load_runtime_dependencies()
    random.seed(42)
    conn = connect()
    try:
        ensure_tables(conn)
        legacy_counts = backfill_legacy_huagao(conn, args.source)
        business_counts = backfill_business_actions(conn)
        items_by_domain = load_items(conn, domains)
        actions = load_actions(conn, domains, args.source)
        profiles, popularity, positive_counts = build_profiles(actions, items_by_domain)
        for known_actor in load_known_actor_keys(conn, domains, args.source):
            profiles[known_actor]
        write_profiles(conn, profiles)
        outputs = generate_recommendations(conn, args, domains, profiles, popularity, positive_counts, items_by_domain)
        activate_outputs(conn, outputs, args.source)
        summary = {
            "domains": domains,
            "source": args.source,
            "topK": args.top_k,
            "legacyBackfill": legacy_counts,
            "businessBackfill": business_counts,
            "actorCount": len(profiles),
            "actions": len(actions),
            "models": {
                domain: {
                    "modelVersion": output["modelVersion"],
                    "metrics": output["metrics"],
                    "recommendationRows": len(output["recommendations"]),
                }
                for domain, output in outputs.items()
            },
        }
        print(json.dumps(summary, ensure_ascii=False, indent=2))
    finally:
        conn.close()


if __name__ == "__main__":
    main()
