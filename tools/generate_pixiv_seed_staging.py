from __future__ import annotations

import hashlib
import json
import re
import unicodedata
from collections import Counter, defaultdict, deque
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = REPO_ROOT / "static" / "pixiv"
UPLOAD_ROOT = REPO_ROOT / "artistsion-admin" / "uploads" / "images"
MYSQL_UPLOAD_DIR = Path(r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads")

CATEGORY_SLUGS = {
    "头像": "touxiang",
    "Q版": "qban",
    "半身像": "banshen",
    "立绘": "lihui",
    "live2d": "live2d",
    "服饰": "fushi",
    "平面设计": "pingmian",
    "表情包": "biaoqing",
    "组合页": "zuhe",
}

CATEGORY_LABELS = {
    "touxiang": "头像",
    "qban": "Q版",
    "banshen": "半身像",
    "lihui": "立绘",
    "live2d": "Live2D",
    "fushi": "服饰",
    "pingmian": "平面设计",
    "biaoqing": "表情包",
    "zuhe": "组合页",
}

CATEGORY_STYLE_TAGS = {
    "touxiang": ["头像委托", "角色头像", "清透上色"],
    "qban": ["Q版角色", "可爱风", "社媒头像"],
    "banshen": ["半身像", "人物表现", "光影塑造"],
    "lihui": ["角色立绘", "设定展示", "全身设计"],
    "live2d": ["Live2D模型", "VTuber", "动态立绘"],
    "fushi": ["服装设定", "服饰参考", "造型设计"],
    "pingmian": ["平面视觉", "版式设计", "宣传海报"],
    "biaoqing": ["表情差分", "互动表情", "轻量头像"],
    "zuhe": ["组合展示", "套图", "系列设计"],
}

STYLE_POOL = [
    "暖色光影",
    "冷色氛围",
    "柔和线条",
    "厚涂质感",
    "日系插画",
    "国风细节",
    "高饱和",
    "清爽配色",
    "幻想角色",
    "学院风",
    "甜系配色",
    "暗色主题",
    "精细线稿",
    "舞台感",
    "复古色调",
    "治愈氛围",
]

ARTIST_NAMES = [
    "青梧", "星澄", "霁川", "月白", "南栀", "岚音", "千鹤", "织夏",
    "砚秋", "白榆", "夕雾", "羽墨", "澜舟", "森屿", "云岫", "初晴",
    "栖迟", "洛眠", "北辰", "绫川", "木槿", "晴野", "雾岛", "知夏",
    "川禾", "鹿鸣", "望舒", "青岚", "庭雪", "星野", "若水", "苏合",
    "映棠", "白露", "夜航", "竹间", "云起", "清和", "珑月", "松见",
    "阿澈", "小满", "风见", "遥川", "秋白", "灯里", "绛河", "浮光",
    "墨庭", "临溪", "晴岚", "观星", "折枝", "朝雨", "遥夜", "浅川",
    "冬青", "千寻", "蓝桥", "栀年", "檐雨", "雪见", "澄怀", "未央",
]

GENERIC_WORDS = {
    "live2d", "live", "model", "models", "showcase", "art", "illust", "illustration",
    "vtuber", "vt", "l2d", "sva", "gen", "commission", "commisson", "comission",
    "依頼絵", "お仕事", "制作実績", "オーダーメイド", "モデル", "キービジュアル付き",
    "無着色", "パーツ分け済み", "汎用モデル", "完売御礼", "対応", "立绘", "头像",
    "无题", "無題", "习作", "新衣装", "衣装", "約稿", "约稿", "稿", "ちゃん", "さん",
    "様", "さま", "png", "jpg", "jpeg",
}

KEYWORD_TAGS = [
    (("新衣装", "衣装"), "新衣装"),
    (("猫", "ねこ", "cat", "kitty"), "猫系"),
    (("竜", "龍", "龙", "dragon", "drag"), "龙族"),
    (("maid", "メイド", "女仆"), "女仆"),
    (("angel", "天使"), "天使"),
    (("nurse", "ナース", "护士"), "护士"),
    (("goth", "ゴスロリ", "洛丽塔", "lolita"), "洛丽塔"),
    (("streetwear", "街头"), "街头风"),
    (("花嫁", "bride"), "花嫁"),
    (("古風", "古风", "国風", "国风"), "国风"),
    (("狐", "きつね", "fox"), "狐系"),
    (("mouse", "鼠"), "鼠系"),
    (("zombie", "僵尸"), "暗黑角色"),
    (("idol", "偶像"), "偶像"),
    (("ribbon", "リボン"), "蝴蝶结"),
    (("blue", "青", "蓝"), "蓝色系"),
]


def sha1_of(path: Path) -> str:
    digest = hashlib.sha1()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def strip_pixiv_prefix(name: str) -> str:
    stem = Path(name).stem
    stem = re.sub(r"^\d+_p\d+[-_]*", "", stem)
    stem = re.sub(r"^\d+[-_]*", "", stem)
    return stem.strip()


def normalize_spaces(value: str) -> str:
    value = unicodedata.normalize("NFKC", value)
    value = re.sub(r"[\[\]【】()（）{}「」『』<>《》]", " ", value)
    value = re.sub(r"[·•|／/\\_~～:：;；,，.。!！?？+*&^%$#@=]+", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def clean_title(original_name: str, category: str, index: int) -> str:
    text = strip_pixiv_prefix(original_name)
    cleaned = normalize_spaces(text)
    cleaned = re.sub(r"\b(live\s*2d|live2d|vtuber|model|showcase|commission|commisson)\b", "", cleaned, flags=re.I)
    cleaned = re.sub(r"\s+", " ", cleaned).strip(" -_")
    if not cleaned or cleaned.lower() in {"无题", "無題", "习作", "bushi"} or re.fullmatch(r"\d+(\.\d+)?", cleaned):
        return f"{CATEGORY_LABELS[category]}风格练习 {index:03d}"
    return cleaned[:60]


def normalized_tag(name: str) -> str:
    normalized = unicodedata.normalize("NFKC", name).strip().lower()
    normalized = re.sub(r"\s+", "", normalized)
    normalized = re.sub(r"[#＃,，;；/／\\|]+", "", normalized)
    return normalized[:100]


def is_useful_token(token: str) -> bool:
    raw = token.strip(" -_")
    if not raw:
        return False
    lowered = raw.lower()
    if lowered in GENERIC_WORDS:
        return False
    if "素材" in raw:
        return False
    if re.fullmatch(r"\d+(\.\d+)?", raw):
        return False
    if len(raw) == 1 and re.fullmatch(r"[a-zA-Z0-9]", raw):
        return False
    return 2 <= len(raw) <= 24


def token_candidates(title: str) -> list[str]:
    cleaned = normalize_spaces(title)
    parts = re.split(r"\s+", cleaned)
    candidates: list[str] = []
    for part in parts:
        part = part.strip()
        if is_useful_token(part):
            candidates.append(part[:24])
        cjk_chunks = re.findall(r"[\u4e00-\u9fff\u3040-\u30ff]{2,12}", part)
        for chunk in cjk_chunks:
            chunk = re.sub(r"(ちゃん|さん|様|さま)$", "", chunk)
            if is_useful_token(chunk):
                candidates.append(chunk[:24])
        latin_chunks = re.findall(r"[A-Za-z][A-Za-z0-9]{2,18}", part)
        for chunk in latin_chunks:
            if is_useful_token(chunk):
                candidates.append(chunk[:24])
    return candidates


def unique(values: list[str]) -> list[str]:
    seen = set()
    result = []
    for value in values:
        value = value.strip()
        key = normalized_tag(value)
        if not value or not key or key in seen or "素材" in value:
            continue
        seen.add(key)
        result.append(value[:48])
    return result


def build_tags(original_name: str, title: str, category: str, domain: str, index: int) -> list[str]:
    lowered = original_name.lower()
    tags: list[str] = []
    tags.extend(token_candidates(title)[:3])
    for needles, tag in KEYWORD_TAGS:
        if any(needle.lower() in lowered or needle in original_name for needle in needles):
            tags.append(tag)
    tags.append(CATEGORY_LABELS[category])
    tags.append(CATEGORY_STYLE_TAGS[category][index % len(CATEGORY_STYLE_TAGS[category])])
    tags.append(STYLE_POOL[index % len(STYLE_POOL)])
    tags.append(STYLE_POOL[(index + 5) % len(STYLE_POOL)])
    if len(unique(tags)) < 3:
        tags.extend([STYLE_POOL[(index + 3) % len(STYLE_POOL)], STYLE_POOL[(index + 7) % len(STYLE_POOL)]])
    return unique(tags)[:7]


def build_records() -> tuple[list[dict], list[dict], list[dict]]:
    source_files = [p for p in SOURCE_ROOT.rglob("*") if p.is_file()]
    upload_files = list(UPLOAD_ROOT.glob("pixivbulk_*.*"))
    if not source_files:
        raise RuntimeError(f"No source files found under {SOURCE_ROOT}")
    if len(source_files) != len(upload_files):
        raise RuntimeError(f"Source/upload count mismatch: {len(source_files)} vs {len(upload_files)}")

    upload_by_hash: dict[tuple[int, str, str], deque[Path]] = defaultdict(deque)
    for upload in upload_files:
        key = (upload.stat().st_size, upload.suffix.lower(), sha1_of(upload))
        upload_by_hash[key].append(upload)

    source_records = []
    for source in source_files:
        slug = CATEGORY_SLUGS.get(source.parent.name)
        if not slug:
            continue
        key = (source.stat().st_size, source.suffix.lower(), sha1_of(source))
        matches = upload_by_hash.get(key)
        if not matches:
            raise RuntimeError(f"Cannot map source file to upload file: {source}")
        upload = matches.popleft()
        source_records.append({
            "source": source,
            "old_photo": upload.name,
            "category": slug,
            "original_name": source.name,
        })

    category_order = {slug: idx for idx, slug in enumerate(CATEGORY_LABELS)}
    source_records.sort(key=lambda row: (category_order[row["category"]], row["source"].name.lower()))

    per_artist_counts: Counter[int] = Counter()
    image_rows: list[dict] = []
    tag_rows: list[dict] = []
    artist_tags: dict[int, list[str]] = defaultdict(list)
    artist_images: dict[int, list[str]] = defaultdict(list)

    for idx, row in enumerate(source_records):
        artist_no = (idx % len(ARTIST_NAMES)) + 1
        per_artist_counts[artist_no] += 1
        domain = "zuopin" if per_artist_counts[artist_no] % 2 == 1 else "huagao"
        title = clean_title(row["original_name"], row["category"], idx + 1)
        tags = build_tags(row["original_name"], title, row["category"], domain, idx)
        artist_tags[artist_no].extend(tags)
        artist_images[artist_no].append(row["old_photo"])
        image_rows.append({
            "oldPhoto": row["old_photo"],
            "originalName": row["original_name"],
            "category": row["category"],
            "categoryLabel": CATEGORY_LABELS[row["category"]],
            "domain": domain,
            "artistNo": artist_no,
            "title": title,
            "itemName": f"{title} 定制橱窗"[:80] if domain == "huagao" else title,
            "content": build_content(title, tags, row["category"], domain),
            "price": price_for(row["category"], idx),
            "dznum": 3 + ((idx * 7) % 180),
            "publishDate": f"2026-05-{(idx % 9) + 1:02d} 10:{idx % 60:02d}:00",
        })
        for tag in tags:
            tag_rows.append({
                "oldPhoto": row["old_photo"],
                "domain": domain,
                "tagName": tag,
                "normalizedName": normalized_tag(tag),
            })

    artist_rows = []
    for artist_no, display_name in enumerate(ARTIST_NAMES, start=1):
        tag_counter = Counter(artist_tags[artist_no])
        style_tags = [tag for tag, _ in tag_counter.most_common(5)]
        if len(style_tags) < 3:
            style_tags.extend(STYLE_POOL[:3])
        images = artist_images[artist_no]
        artist_rows.append({
            "artistNo": artist_no,
            "oldUsername": f"pixiv_bulk_artist_{artist_no:03d}",
            "newUsername": f"atelier_{artist_no:03d}",
            "displayName": display_name,
            "bio": f"擅长{style_tags[0]}、{style_tags[1]}和{style_tags[2]}方向，作品覆盖角色展示与委托橱窗。",
            "styleTags": ",".join(unique(style_tags)[:5]),
            "avatar": images[0] if images else "",
            "coverImage": images[1] if len(images) > 1 else (images[0] if images else ""),
        })

    return artist_rows, image_rows, tag_rows


def build_content(title: str, tags: list[str], category: str, domain: str) -> str:
    tag_text = "、".join(tags[:4])
    if domain == "zuopin":
        return f"围绕《{title}》完成的公开作品，重点展示{CATEGORY_LABELS[category]}方向的角色设定、完成度与画面风格。标签线索：{tag_text}。"
    return f"可承接《{title}》相关方向的定制委托，适合用于{CATEGORY_LABELS[category]}、角色展示和商业展示场景。参考标签：{tag_text}。"


def price_for(category: str, index: int) -> str:
    base = {
        "touxiang": 80,
        "qban": 120,
        "banshen": 180,
        "lihui": 360,
        "live2d": 680,
        "fushi": 260,
        "pingmian": 220,
        "biaoqing": 60,
        "zuhe": 480,
    }[category]
    return f"{base + (index % 9) * 20:.2f}"


def write_chunks(prefix: str, rows: list[dict], chunk_size: int) -> list[Path]:
    MYSQL_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    paths = []
    for idx in range(0, len(rows), chunk_size):
        chunk = rows[idx:idx + chunk_size]
        path = MYSQL_UPLOAD_DIR / f"{prefix}_{idx // chunk_size + 1:02d}.json"
        path.write_text(json.dumps(chunk, ensure_ascii=False), encoding="utf-8")
        paths.append(path)
    return paths


def main() -> None:
    artist_rows, image_rows, tag_rows = build_records()
    artist_paths = write_chunks("artistsion_pixiv_artist_profiles", artist_rows, 80)
    image_paths = write_chunks("artistsion_pixiv_image_map", image_rows, 450)
    tag_paths = write_chunks("artistsion_pixiv_tag_map", tag_rows, 800)
    summary = {
        "artists": len(artist_rows),
        "images": len(image_rows),
        "tags": len(tag_rows),
        "domainCounts": dict(Counter(row["domain"] for row in image_rows)),
        "artistFiles": [str(path) for path in artist_paths],
        "imageFiles": [str(path) for path in image_paths],
        "tagFiles": [str(path) for path in tag_paths],
    }
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
