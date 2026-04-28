import argparse
import hashlib
import json
import math
import os
import random
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path


STATUS_OK = "审核成功"
TYPE_ON_SALE = "上架"
SYN_PREFIX = "syn_"
SYN_ITEM_MARK = "synthetic_ltr"
DEFAULT_CATEGORIES = ["头像", "立绘", "插画", "Q版", "场景", "同人"]

np = None
pymysql = None
XGBRanker = None


def load_runtime_dependencies():
    global np, pymysql, XGBRanker
    try:
        import numpy as numpy_module
        import pymysql as pymysql_module
        from xgboost import XGBRanker as xgb_ranker
    except ImportError as exc:
        requirements = Path(__file__).resolve().with_name("requirements.txt")
        raise SystemExit(
            "Missing Python dependency: %s. Install with: pip install -r %s"
            % (exc.name, requirements)
        ) from exc
    np = numpy_module
    pymysql = pymysql_module
    XGBRanker = xgb_ranker


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


def ensure_recommendation_tables(conn):
    ddl_model = """
    CREATE TABLE IF NOT EXISTS rec_huagao_model_version (
      model_version VARCHAR(64) NOT NULL,
      algorithm VARCHAR(64) NOT NULL,
      train_source VARCHAR(32) NOT NULL,
      model_path VARCHAR(255) DEFAULT NULL,
      metrics_json TEXT DEFAULT NULL,
      sample_count BIGINT NOT NULL DEFAULT 0,
      positive_sample_count BIGINT NOT NULL DEFAULT 0,
      actor_count BIGINT NOT NULL DEFAULT 0,
      item_count BIGINT NOT NULL DEFAULT 0,
      status VARCHAR(32) NOT NULL DEFAULT 'active',
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      trained_at DATETIME DEFAULT NULL,
      activated_at DATETIME DEFAULT NULL,
      PRIMARY KEY (model_version),
      KEY idx_rec_hg_model_status_activated (status, activated_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """
    ddl_recs = """
    CREATE TABLE IF NOT EXISTS rec_huagao_user_recommendation (
      id BIGINT NOT NULL AUTO_INCREMENT,
      model_version VARCHAR(64) NOT NULL,
      actor_key VARCHAR(80) NOT NULL,
      huagao_id BIGINT NOT NULL,
      rank_no INT NOT NULL,
      score DECIMAL(18,8) NOT NULL DEFAULT 0,
      reason VARCHAR(255) DEFAULT NULL,
      generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_rec_hg_user_model_rank (model_version, actor_key, rank_no),
      UNIQUE KEY uk_rec_hg_user_model_item (model_version, actor_key, huagao_id),
      KEY idx_rec_hg_user_actor_rank (actor_key, model_version, rank_no),
      KEY idx_rec_hg_user_item (huagao_id),
      KEY idx_rec_hg_user_generated (generated_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """
    with conn.cursor() as cur:
        cur.execute(ddl_model)
        cur.execute(ddl_recs)
    conn.commit()


def old_synthetic_dates(conn):
    sql = """
    SELECT DISTINCT DATE(created_at) AS dt FROM rec_huagao_request_log WHERE request_id LIKE %s
    UNION
    SELECT DISTINCT DATE(created_at) AS dt FROM rec_huagao_impression_log WHERE request_id LIKE %s
    UNION
    SELECT DISTINCT DATE(created_at) AS dt FROM rec_huagao_action_log WHERE request_id LIKE %s OR event_id LIKE %s
    """
    with conn.cursor() as cur:
        cur.execute(sql, (SYN_PREFIX + "%", SYN_PREFIX + "%", SYN_PREFIX + "%", SYN_PREFIX + "%"))
        return {row["dt"] for row in cur.fetchall() if row["dt"] is not None}


def reset_synthetic(conn):
    with conn.cursor() as cur:
        cur.execute("DELETE FROM rec_huagao_action_log WHERE request_id LIKE %s OR event_id LIKE %s",
                    (SYN_PREFIX + "%", SYN_PREFIX + "%"))
        cur.execute("DELETE FROM rec_huagao_impression_log WHERE request_id LIKE %s", (SYN_PREFIX + "%",))
        cur.execute("DELETE FROM rec_huagao_request_log WHERE request_id LIKE %s", (SYN_PREFIX + "%",))
        cur.execute("""
            DELETE r FROM rec_huagao_user_recommendation r
            INNER JOIN rec_huagao_model_version m ON m.model_version = r.model_version
            WHERE m.train_source = 'synthetic'
        """)
        cur.execute("DELETE FROM rec_huagao_model_version WHERE train_source = 'synthetic'")
        cur.execute("DELETE FROM sys_huagao WHERE fujin = %s", (SYN_ITEM_MARK,))
    conn.commit()


def active_items(conn):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT id, name, price, fenlei, shangjiaids
            FROM sys_huagao
            WHERE status = %s AND type = %s
            ORDER BY id
        """, (STATUS_OK, TYPE_ON_SALE))
        return cur.fetchall()


def ensure_synthetic_items(conn, min_items, rng):
    items = active_items(conn)
    if len(items) >= min_items:
        return items

    need = min_items - len(items)
    rows = []
    for idx in range(need):
        category = DEFAULT_CATEGORIES[idx % len(DEFAULT_CATEGORIES)]
        price = round(rng.uniform(60, 900), 2)
        artist_id = 90000 + (idx % 12)
        rows.append((
            "Synthetic LTR Huagao %02d" % (idx + 1),
            "",
            price,
            category,
            "Synthetic item for local recommendation training.",
            TYPE_ON_SALE,
            str(artist_id),
            STATUS_OK,
            0,
            SYN_ITEM_MARK,
        ))
    with conn.cursor() as cur:
        cur.executemany("""
            INSERT INTO sys_huagao (name, photo, price, fenlei, content, type, shangjiaids, status, zhekou, fujin)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, rows)
    conn.commit()
    return active_items(conn)


def stable_hash(value):
    raw = "" if value is None else str(value)
    return int(hashlib.md5(raw.encode("utf-8")).hexdigest()[:8], 16)


def query_key(*parts):
    return hashlib.md5("|".join("" if p is None else str(p) for p in parts).encode("utf-8")).hexdigest()


def synthetic_actor(idx):
    if idx % 2 == 0:
        user_id = 100000 + idx
        return {"actor_key": "u:%d" % user_id, "user_id": user_id, "visitor_id": None}
    visitor_id = "synthetic_visitor_%03d" % idx
    return {"actor_key": "v:%s" % visitor_id, "user_id": None, "visitor_id": visitor_id}


def score_item_for_actor(item, preferred_categories, preferred_artists, rng):
    score = rng.random() * 0.22
    if item.get("fenlei") in preferred_categories:
        score += 0.52
    if str(item.get("shangjiaids") or "") in preferred_artists:
        score += 0.22
    price = float(item.get("price") or 0)
    if 80 <= price <= 600:
        score += 0.12
    return score


def relevance_from_score(score, rng):
    score += rng.random() * 0.08
    if score >= 0.88:
        return 4
    if score >= 0.74:
        return 3
    if score >= 0.58:
        return 2
    if score >= 0.42:
        return 1
    return 0


def generate_synthetic_logs(conn, args, items, rng):
    run_id = datetime.now().strftime("%Y%m%d%H%M%S")
    page_size = min(args.page_size, len(items))
    base_time = datetime.now() - timedelta(minutes=args.actors * args.requests_per_actor)
    request_rows = []
    impression_rows = []
    action_rows = []

    categories = sorted({item.get("fenlei") for item in items if item.get("fenlei")}) or DEFAULT_CATEGORIES
    artists = sorted({str(item.get("shangjiaids") or "") for item in items if item.get("shangjiaids")})

    for actor_idx in range(args.actors):
        actor = synthetic_actor(actor_idx)
        preferred_categories = set(rng.sample(categories, min(2, len(categories))))
        preferred_artists = set(rng.sample(artists, min(2, len(artists)))) if artists else set()
        session_id = "synthetic_session_%03d" % actor_idx

        for req_idx in range(args.requests_per_actor):
            created_at = base_time + timedelta(minutes=(actor_idx * args.requests_per_actor) + req_idx)
            request_id = "%s%s_%03d_%03d" % (SYN_PREFIX, run_id, actor_idx, req_idx)
            ranked = sorted(
                items,
                key=lambda item: score_item_for_actor(item, preferred_categories, preferred_artists, rng),
                reverse=True,
            )
            start = (req_idx * 3) % max(1, len(ranked))
            candidates = (ranked[start:] + ranked[:start])[:page_size]

            request_rows.append((
                request_id,
                query_key("synthetic", actor["actor_key"], req_idx),
                "home",
                actor["user_id"],
                actor["visitor_id"],
                session_id,
                None,
                None,
                None,
                None,
                1,
                page_size,
                "synthetic_ltr",
                0,
                0,
                0,
                len(items),
                len(candidates),
                created_at,
            ))

            for pos, item in enumerate(candidates, start=1):
                item_score = score_item_for_actor(item, preferred_categories, preferred_artists, rng)
                relevance = relevance_from_score(item_score, rng)
                impression_rows.append((
                    request_id,
                    item["id"],
                    parse_int(item.get("shangjiaids")),
                    pos,
                    1,
                    page_size,
                    "home",
                    None,
                    None,
                    None,
                    None,
                    int(round(item_score * 100)),
                    created_at,
                ))
                action_rows.extend(build_action_rows(
                    run_id,
                    actor,
                    session_id,
                    request_id,
                    item,
                    pos,
                    relevance,
                    created_at,
                ))

    with conn.cursor() as cur:
        cur.executemany("""
            INSERT INTO rec_huagao_request_log (
                request_id, query_key, scene, user_id, visitor_id, session_id,
                keyword, normalized_keyword, fenlei, tag_id,
                page_no, page_size, sort_mode,
                has_search, has_fenlei_filter, has_tag_filter,
                result_total, returned_count, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, request_rows)
        cur.executemany("""
            INSERT INTO rec_huagao_impression_log (
                request_id, huagao_id, shangjia_id, position, page_no, page_size,
                scene, keyword, normalized_keyword, fenlei, tag_id, search_score, created_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, impression_rows)
        if action_rows:
            cur.executemany("""
                INSERT INTO rec_huagao_action_log (
                    event_id, event_type, request_id, huagao_id, shangjia_id,
                    user_id, visitor_id, session_id, position, event_value, scene, source, created_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, action_rows)
    conn.commit()
    return {row[18].date() for row in request_rows}


def build_action_rows(run_id, actor, session_id, request_id, item, position, relevance, created_at):
    if relevance <= 0:
        return []
    base = "%s%s_%s_%s" % (SYN_PREFIX, run_id[-8:], request_id[-7:], item["id"])
    event_types = ["click_detail", "detail_view"]
    if relevance >= 2:
        event_types.append("favorite")
    if relevance >= 3:
        event_types.append("add_to_cart")
    if relevance >= 4:
        event_types.append("create_order")
    event_types.append("detail_dwell")

    rows = []
    for idx, event_type in enumerate(event_types):
        event_value = 8000 + (relevance * 2500) if event_type == "detail_dwell" else None
        rows.append((
            "%s_%02d" % (base, idx),
            event_type,
            request_id,
            item["id"],
            parse_int(item.get("shangjiaids")),
            actor["user_id"],
            actor["visitor_id"],
            session_id,
            position,
            event_value,
            "home",
            "synthetic_ltr",
            created_at + timedelta(seconds=idx + 1),
        ))
    return rows


def parse_int(value):
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def load_training_rows(conn):
    sql = """
    SELECT
        r.request_id,
        CASE
            WHEN r.user_id IS NOT NULL THEN CONCAT('u:', r.user_id)
            WHEN r.visitor_id IS NOT NULL AND r.visitor_id <> '' THEN CONCAT('v:', r.visitor_id)
            ELSE 'global'
        END AS actor_key,
        i.huagao_id,
        i.position,
        COALESCE(i.search_score, 0) AS search_score,
        COALESCE(h.price, 0) AS price,
        h.fenlei,
        h.shangjiaids,
        CASE
            WHEN COALESCE(a.create_order_cnt, 0) > 0 THEN 4
            WHEN COALESCE(a.add_cart_cnt, 0) > 0 THEN 3
            WHEN COALESCE(a.favorite_cnt, 0) > 0 THEN 2
            WHEN COALESCE(a.click_detail_cnt, 0) > 0 THEN 1
            ELSE 0
        END AS relevance
    FROM rec_huagao_request_log r
    INNER JOIN rec_huagao_impression_log i ON i.request_id = r.request_id
    INNER JOIN sys_huagao h ON h.id = i.huagao_id
    LEFT JOIN (
        SELECT
            request_id,
            huagao_id,
            SUM(CASE WHEN event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
            SUM(CASE WHEN event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
            SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_cart_cnt,
            SUM(CASE WHEN event_type = 'create_order' THEN 1 ELSE 0 END) AS create_order_cnt
        FROM rec_huagao_action_log
        WHERE request_id LIKE %s
        GROUP BY request_id, huagao_id
    ) a ON a.request_id = i.request_id AND a.huagao_id = i.huagao_id
    WHERE r.request_id LIKE %s
    ORDER BY r.request_id, i.position
    """
    with conn.cursor() as cur:
        cur.execute(sql, (SYN_PREFIX + "%", SYN_PREFIX + "%"))
        return cur.fetchall()


class FeatureStore:
    def __init__(self, rows):
        self.item_stats = defaultdict(lambda: {"cnt": 0, "sum": 0.0, "pos": 0})
        self.actor_category = defaultdict(lambda: defaultdict(float))
        self.actor_artist = defaultdict(lambda: defaultdict(float))
        self.global_category = defaultdict(float)
        self.global_artist = defaultdict(float)
        self.max_item_id = max([int(row["huagao_id"]) for row in rows] + [1])

        for row in rows:
            label = float(row["relevance"])
            item_id = int(row["huagao_id"])
            actor_key = row["actor_key"]
            category = row.get("fenlei") or ""
            artist = str(row.get("shangjiaids") or "")
            self.item_stats[item_id]["cnt"] += 1
            self.item_stats[item_id]["sum"] += label
            self.item_stats[item_id]["pos"] += 1 if label > 0 else 0
            self.actor_category[actor_key][category] += label
            self.actor_artist[actor_key][artist] += label
            self.global_category[category] += label
            self.global_artist[artist] += label

    def row_features(self, row, actor_key=None, position=None):
        actor = actor_key or row["actor_key"]
        item_id = int(row["huagao_id"])
        stats = self.item_stats[item_id]
        cnt = max(stats["cnt"], 1)
        category = row.get("fenlei") or ""
        artist = str(row.get("shangjiaids") or "")
        price = float(row.get("price") or 0)
        item_mean = stats["sum"] / cnt
        item_pos_rate = stats["pos"] / cnt
        cat_affinity = self.global_category[category] if actor == "global" else self.actor_category[actor][category]
        artist_affinity = self.global_artist[artist] if actor == "global" else self.actor_artist[actor][artist]
        return [
            float(position if position is not None else row.get("position") or 0) / 100.0,
            math.log1p(price) / 10.0,
            float(row.get("search_score") or 0) / 100.0,
            item_mean / 4.0,
            item_pos_rate,
            math.log1p(cat_affinity) / 5.0,
            math.log1p(artist_affinity) / 5.0,
            (stable_hash(category) % 1000) / 1000.0,
            (parse_int(artist) or 0) / 100000.0,
            item_id / max(self.max_item_id, 1),
        ]


def build_grouped_dataset(rows, feature_store):
    X, y, request_ids = [], [], []
    for row in rows:
        X.append(feature_store.row_features(row))
        y.append(float(row["relevance"]))
        request_ids.append(row["request_id"])
    groups = []
    last = None
    count = 0
    for request_id in request_ids:
        if last is None:
            last = request_id
        if request_id != last:
            groups.append(count)
            last = request_id
            count = 0
        count += 1
    if count:
        groups.append(count)
    return np.asarray(X, dtype=np.float32), np.asarray(y, dtype=np.float32), groups


def split_by_group(X, y, groups, train_ratio=0.8):
    split_group_count = max(1, int(len(groups) * train_ratio))
    train_size = sum(groups[:split_group_count])
    train_groups = groups[:split_group_count]
    test_groups = groups[split_group_count:] or groups[-1:]
    if split_group_count >= len(groups):
        return X, y, groups, X, y, groups
    return X[:train_size], y[:train_size], train_groups, X[train_size:], y[train_size:], test_groups


def dcg(labels):
    return sum((2 ** label - 1) / math.log2(idx + 2) for idx, label in enumerate(labels))


def ndcg_at(y_true, y_score, groups, k):
    scores = []
    start = 0
    for group_size in groups:
        end = start + group_size
        labels = y_true[start:end]
        preds = y_score[start:end]
        order = np.argsort(-preds)[:k]
        ideal = np.argsort(-labels)[:k]
        ideal_dcg = dcg(labels[ideal])
        scores.append(0.0 if ideal_dcg == 0 else dcg(labels[order]) / ideal_dcg)
        start = end
    return float(np.mean(scores)) if scores else 0.0


def map_at(y_true, y_score, groups, k):
    maps = []
    start = 0
    for group_size in groups:
        end = start + group_size
        labels = y_true[start:end]
        preds = y_score[start:end]
        order = np.argsort(-preds)[:k]
        hits = 0
        precisions = []
        for rank, idx in enumerate(order, start=1):
            if labels[idx] > 0:
                hits += 1
                precisions.append(hits / rank)
        maps.append(float(np.mean(precisions)) if precisions else 0.0)
        start = end
    return float(np.mean(maps)) if maps else 0.0


def train_ranker(rows):
    feature_store = FeatureStore(rows)
    X, y, groups = build_grouped_dataset(rows, feature_store)
    X_train, y_train, train_groups, X_test, y_test, test_groups = split_by_group(X, y, groups)
    model = XGBRanker(
        objective="rank:ndcg",
        n_estimators=80,
        max_depth=4,
        learning_rate=0.08,
        subsample=0.9,
        colsample_bytree=0.9,
        random_state=20260428,
    )
    model.fit(X_train, y_train, group=train_groups, verbose=False)
    preds = model.predict(X_test)
    metrics = {
        "ndcg@5": ndcg_at(y_test, preds, test_groups, 5),
        "ndcg@10": ndcg_at(y_test, preds, test_groups, 10),
        "map@10": map_at(y_test, preds, test_groups, 10),
        "sample_count": int(len(rows)),
        "positive_sample_count": int(sum(1 for row in rows if row["relevance"] > 0)),
        "actor_count": int(len({row["actor_key"] for row in rows})),
        "item_count": int(len({row["huagao_id"] for row in rows})),
        "group_count": int(len(groups)),
    }
    return model, feature_store, metrics


def insert_recommendations(conn, model, feature_store, rows, items, args, model_version, model_path, metrics):
    actors = sorted({row["actor_key"] for row in rows})
    actors.append("global")
    item_lookup_rows = [
        {
            "huagao_id": item["id"],
            "price": item.get("price") or 0,
            "fenlei": item.get("fenlei") or "",
            "shangjiaids": item.get("shangjiaids") or "",
            "position": 0,
            "search_score": 0,
        }
        for item in items
    ]
    rec_rows = []
    generated_at = datetime.now()
    for actor in actors:
        feature_matrix = np.asarray(
            [feature_store.row_features(item, actor_key=actor, position=0) for item in item_lookup_rows],
            dtype=np.float32,
        )
        scores = model.predict(feature_matrix)
        order = np.argsort(-scores)[: min(args.top_k, len(item_lookup_rows))]
        for rank, idx in enumerate(order, start=1):
            item = item_lookup_rows[idx]
            rec_rows.append((
                model_version,
                actor,
                item["huagao_id"],
                rank,
                float(scores[idx]),
                "xgboost_ltr_synthetic",
                generated_at,
            ))

    with conn.cursor() as cur:
        cur.execute("UPDATE rec_huagao_model_version SET status = 'archived' WHERE status = 'active'")
        cur.execute("""
            INSERT INTO rec_huagao_model_version (
                model_version, algorithm, train_source, model_path, metrics_json,
                sample_count, positive_sample_count, actor_count, item_count,
                status, created_at, trained_at, activated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'active', %s, %s, %s)
        """, (
            model_version,
            "xgboost_rank_ndcg",
            args.source,
            str(model_path),
            json.dumps(metrics, ensure_ascii=False),
            metrics["sample_count"],
            metrics["positive_sample_count"],
            metrics["actor_count"],
            metrics["item_count"],
            generated_at,
            generated_at,
            generated_at,
        ))
        cur.executemany("""
            INSERT INTO rec_huagao_user_recommendation (
                model_version, actor_key, huagao_id, rank_no, score, reason, generated_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, rec_rows)
    conn.commit()
    return len(rec_rows), len(actors)


def rebuild_daily_aggregates(conn, dates):
    if not dates:
        return
    for dt in sorted(dates):
        try:
            rebuild_one_day(conn, dt)
        except Exception as exc:
            print("WARN: failed to rebuild aggregates for %s: %s" % (dt, exc))
            conn.rollback()


def rebuild_one_day(conn, dt):
    with conn.cursor() as cur:
        cur.execute("DELETE FROM rec_huagao_item_stat_daily WHERE dt = %s", (dt,))
        cur.execute("""
            INSERT INTO rec_huagao_item_stat_daily (
                dt, huagao_id, shangjia_id, impression_cnt, click_detail_cnt, detail_view_cnt,
                detail_dwell_cnt, detail_dwell_total_ms, favorite_cnt, add_cart_cnt, create_order_cnt,
                search_impression_cnt, filter_fenlei_impression_cnt, filter_tag_impression_cnt,
                search_click_detail_cnt, search_detail_view_cnt, search_detail_dwell_cnt,
                search_detail_dwell_total_ms, search_favorite_cnt, search_add_cart_cnt, search_create_order_cnt
            )
            WITH impression_raw AS (
                SELECT DATE(created_at) AS dt, huagao_id, MAX(shangjia_id) AS shangjia_id,
                       COUNT(*) AS impression_cnt,
                       SUM(CASE WHEN keyword IS NOT NULL AND keyword <> '' THEN 1 ELSE 0 END) AS search_impression_cnt,
                       SUM(CASE WHEN fenlei IS NOT NULL AND fenlei <> '' THEN 1 ELSE 0 END) AS filter_fenlei_impression_cnt,
                       SUM(CASE WHEN tag_id IS NOT NULL THEN 1 ELSE 0 END) AS filter_tag_impression_cnt
                FROM rec_huagao_impression_log
                WHERE DATE(created_at) = %s
                GROUP BY DATE(created_at), huagao_id
            ),
            action_raw AS (
                SELECT DATE(a.created_at) AS dt, a.huagao_id, MAX(a.shangjia_id) AS shangjia_id,
                       SUM(CASE WHEN a.event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_view' THEN 1 ELSE 0 END) AS detail_view_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_dwell' THEN 1 ELSE 0 END) AS detail_dwell_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_dwell' THEN COALESCE(a.event_value, 0) ELSE 0 END) AS detail_dwell_total_ms,
                       SUM(CASE WHEN a.event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
                       SUM(CASE WHEN a.event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_cart_cnt,
                       SUM(CASE WHEN a.event_type = 'create_order' THEN 1 ELSE 0 END) AS create_order_cnt,
                       SUM(CASE WHEN a.event_type = 'click_detail' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_click_detail_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_view' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_detail_view_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_dwell' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_detail_dwell_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_dwell' AND COALESCE(r.has_search, 0) = 1 THEN COALESCE(a.event_value, 0) ELSE 0 END) AS search_detail_dwell_total_ms,
                       SUM(CASE WHEN a.event_type = 'favorite' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_favorite_cnt,
                       SUM(CASE WHEN a.event_type = 'add_to_cart' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_add_cart_cnt,
                       SUM(CASE WHEN a.event_type = 'create_order' AND COALESCE(r.has_search, 0) = 1 THEN 1 ELSE 0 END) AS search_create_order_cnt
                FROM rec_huagao_action_log a
                LEFT JOIN rec_huagao_request_log r ON r.request_id = a.request_id
                WHERE DATE(a.created_at) = %s
                GROUP BY DATE(a.created_at), a.huagao_id
            ),
            keyset AS (
                SELECT dt, huagao_id FROM impression_raw
                UNION
                SELECT dt, huagao_id FROM action_raw
            )
            SELECT
                k.dt, k.huagao_id, COALESCE(i.shangjia_id, a.shangjia_id),
                COALESCE(i.impression_cnt, 0), COALESCE(a.click_detail_cnt, 0),
                COALESCE(a.detail_view_cnt, 0), COALESCE(a.detail_dwell_cnt, 0),
                COALESCE(a.detail_dwell_total_ms, 0), COALESCE(a.favorite_cnt, 0),
                COALESCE(a.add_cart_cnt, 0), COALESCE(a.create_order_cnt, 0),
                COALESCE(i.search_impression_cnt, 0), COALESCE(i.filter_fenlei_impression_cnt, 0),
                COALESCE(i.filter_tag_impression_cnt, 0), COALESCE(a.search_click_detail_cnt, 0),
                COALESCE(a.search_detail_view_cnt, 0), COALESCE(a.search_detail_dwell_cnt, 0),
                COALESCE(a.search_detail_dwell_total_ms, 0), COALESCE(a.search_favorite_cnt, 0),
                COALESCE(a.search_add_cart_cnt, 0), COALESCE(a.search_create_order_cnt, 0)
            FROM keyset k
            LEFT JOIN impression_raw i ON i.dt = k.dt AND i.huagao_id = k.huagao_id
            LEFT JOIN action_raw a ON a.dt = k.dt AND a.huagao_id = k.huagao_id
        """, (dt, dt))

        cur.execute("DELETE FROM rec_huagao_query_stat_daily WHERE dt = %s", (dt,))
        cur.execute("""
            INSERT INTO rec_huagao_query_stat_daily (
                dt, query_key, scene, keyword, normalized_keyword, fenlei, tag_id,
                has_search, has_fenlei_filter, has_tag_filter,
                request_cnt, impression_cnt, click_detail_cnt, detail_view_cnt,
                detail_dwell_cnt, detail_dwell_total_ms, favorite_cnt, add_cart_cnt, create_order_cnt
            )
            WITH request_raw AS (
                SELECT DATE(created_at) AS dt, query_key, MAX(scene) AS scene, MAX(keyword) AS keyword,
                       MAX(normalized_keyword) AS normalized_keyword, MAX(fenlei) AS fenlei, MAX(tag_id) AS tag_id,
                       MAX(has_search) AS has_search, MAX(has_fenlei_filter) AS has_fenlei_filter,
                       MAX(has_tag_filter) AS has_tag_filter, COUNT(*) AS request_cnt
                FROM rec_huagao_request_log
                WHERE DATE(created_at) = %s
                GROUP BY DATE(created_at), query_key
            ),
            impression_raw AS (
                SELECT DATE(i.created_at) AS dt, r.query_key, COUNT(*) AS impression_cnt
                FROM rec_huagao_impression_log i
                INNER JOIN rec_huagao_request_log r ON r.request_id = i.request_id
                WHERE DATE(i.created_at) = %s
                GROUP BY DATE(i.created_at), r.query_key
            ),
            action_raw AS (
                SELECT DATE(a.created_at) AS dt, r.query_key,
                       SUM(CASE WHEN a.event_type = 'click_detail' THEN 1 ELSE 0 END) AS click_detail_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_view' THEN 1 ELSE 0 END) AS detail_view_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_dwell' THEN 1 ELSE 0 END) AS detail_dwell_cnt,
                       SUM(CASE WHEN a.event_type = 'detail_dwell' THEN COALESCE(a.event_value, 0) ELSE 0 END) AS detail_dwell_total_ms,
                       SUM(CASE WHEN a.event_type = 'favorite' THEN 1 ELSE 0 END) AS favorite_cnt,
                       SUM(CASE WHEN a.event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_cart_cnt,
                       SUM(CASE WHEN a.event_type = 'create_order' THEN 1 ELSE 0 END) AS create_order_cnt
                FROM rec_huagao_action_log a
                INNER JOIN rec_huagao_request_log r ON r.request_id = a.request_id
                WHERE DATE(a.created_at) = %s
                GROUP BY DATE(a.created_at), r.query_key
            ),
            keyset AS (
                SELECT dt, query_key FROM request_raw
                UNION
                SELECT dt, query_key FROM impression_raw
                UNION
                SELECT dt, query_key FROM action_raw
            )
            SELECT
                k.dt, k.query_key, rq.scene, rq.keyword, rq.normalized_keyword, rq.fenlei, rq.tag_id,
                COALESCE(rq.has_search, 0), COALESCE(rq.has_fenlei_filter, 0), COALESCE(rq.has_tag_filter, 0),
                COALESCE(rq.request_cnt, 0), COALESCE(ir.impression_cnt, 0),
                COALESCE(ar.click_detail_cnt, 0), COALESCE(ar.detail_view_cnt, 0),
                COALESCE(ar.detail_dwell_cnt, 0), COALESCE(ar.detail_dwell_total_ms, 0),
                COALESCE(ar.favorite_cnt, 0), COALESCE(ar.add_cart_cnt, 0), COALESCE(ar.create_order_cnt, 0)
            FROM keyset k
            LEFT JOIN request_raw rq ON rq.dt = k.dt AND rq.query_key = k.query_key
            LEFT JOIN impression_raw ir ON ir.dt = k.dt AND ir.query_key = k.query_key
            LEFT JOIN action_raw ar ON ar.dt = k.dt AND ar.query_key = k.query_key
        """, (dt, dt, dt))
    conn.commit()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", choices=["synthetic"], default="synthetic")
    parser.add_argument("--top-k", type=int, default=50)
    parser.add_argument("--actors", type=int, default=40)
    parser.add_argument("--requests-per-actor", type=int, default=8)
    parser.add_argument("--page-size", type=int, default=12)
    parser.add_argument("--min-active-items", type=int, default=24)
    parser.add_argument("--seed", type=int, default=20260428)
    parser.add_argument("--keep-synthetic", action="store_true")
    args = parser.parse_args()

    load_runtime_dependencies()

    rng = random.Random(args.seed)
    conn = connect()
    try:
        ensure_recommendation_tables(conn)
        dates_to_rebuild = old_synthetic_dates(conn)
        if not args.keep_synthetic:
            reset_synthetic(conn)
        items = ensure_synthetic_items(conn, args.min_active_items, rng)
        dates_to_rebuild.update(generate_synthetic_logs(conn, args, items, rng))
        rows = load_training_rows(conn)
        if not rows:
            raise RuntimeError("No synthetic training rows were generated.")

        model, feature_store, metrics = train_ranker(rows)
        model_version = "xgb_ltr_syn_%s" % datetime.now().strftime("%Y%m%d%H%M%S")
        artifacts_dir = Path(__file__).resolve().parent / "artifacts"
        artifacts_dir.mkdir(parents=True, exist_ok=True)
        model_path = artifacts_dir / ("%s.json" % model_version)
        metrics_path = artifacts_dir / ("%s.metrics.json" % model_version)
        model.save_model(str(model_path))
        metrics_path.write_text(json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8")

        rec_count, actor_count = insert_recommendations(
            conn, model, feature_store, rows, items, args, model_version, model_path, metrics
        )
        rebuild_daily_aggregates(conn, dates_to_rebuild)
        print(json.dumps({
            "modelVersion": model_version,
            "modelPath": str(model_path),
            "metricsPath": str(metrics_path),
            "metrics": metrics,
            "recommendationRows": rec_count,
            "recommendationActors": actor_count,
        }, ensure_ascii=False, indent=2))
    finally:
        conn.close()


if __name__ == "__main__":
    main()
