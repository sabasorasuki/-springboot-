#!/usr/bin/env python3
import argparse
import datetime as dt
import json
import os
import re
from decimal import Decimal
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


MAX_SAMPLE_LIMIT = 50
DEFAULT_SAMPLE_LIMIT = 10
DEFAULT_SQL_LIMIT = 50
REPO_ROOT = Path(__file__).resolve().parent.parent
LOCAL_ENV_FILE = REPO_ROOT / "tools" / "db_readonly.local.env"
SPRING_APP_FILE = REPO_ROOT / "artistsion-admin" / "src" / "main" / "resources" / "application.properties"
SPRING_LOCAL_FILE = REPO_ROOT / "artistsion-admin" / "src" / "main" / "resources" / "application-local.properties"
TABLE_NAME_RE = re.compile(r"^[A-Za-z0-9_]+$")
JDBC_URL_RE = re.compile(r"^jdbc:mysql://(?P<host>[^:/?#]+)(?::(?P<port>\d+))?/(?P<db>[^?]+)")
FORBIDDEN_SQL_RE = re.compile(
    r"\b("
    r"insert|update|delete|drop|alter|truncate|create|replace|rename|grant|revoke|"
    r"call|exec|execute|handler|load|outfile|infile|set|use|lock|unlock|kill|"
    r"analyze|optimize|repair|do"
    r")\b",
    re.IGNORECASE,
)
LOCKING_SELECT_RE = re.compile(
    r"\b(for\s+update|lock\s+in\s+share\s+mode)\b",
    re.IGNORECASE,
)
LIMIT_AT_END_RE = re.compile(
    r"""
    \blimit\s+
    (?P<first>\d+)
    (?:
        \s*,\s*(?P<second>\d+)
        |
        \s+offset\s+(?P<offset>\d+)
    )?
    \s*$
    """,
    re.IGNORECASE | re.VERBOSE,
)


class ReadOnlyDbError(Exception):
    pass


def json_print(payload: Dict[str, Any], exit_code: int = 0) -> None:
    print(json.dumps(to_json_safe(payload), ensure_ascii=False, indent=2))
    raise SystemExit(exit_code)


def to_json_safe(value: Any) -> Any:
    if isinstance(value, dict):
        return {str(key): to_json_safe(item) for key, item in value.items()}
    if isinstance(value, list):
        return [to_json_safe(item) for item in value]
    if isinstance(value, tuple):
        return [to_json_safe(item) for item in value]
    if isinstance(value, Decimal):
        return int(value) if value == value.to_integral_value() else float(value)
    if isinstance(value, (dt.datetime, dt.date, dt.time)):
        return value.isoformat()
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value


def success_payload(command: str, data: Any, **extra: Any) -> Dict[str, Any]:
    payload = {
        "ok": True,
        "command": command,
        "data": data,
    }
    payload.update(extra)
    return payload


def error_payload(error_type: str, message: str, **extra: Any) -> Dict[str, Any]:
    payload = {
        "ok": False,
        "error": {
            "type": error_type,
            "message": message,
        },
    }
    if extra:
        payload["meta"] = extra
    return payload


def require_table_name(table: str) -> str:
    if not TABLE_NAME_RE.match(table):
        raise ReadOnlyDbError("Invalid table name. Only letters, numbers, and underscores are allowed.")
    return table


def load_key_value_file(path: Path) -> Dict[str, str]:
    values: Dict[str, str] = {}
    if not path.exists():
        return values

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def extract_default_placeholder(raw_value: str) -> str:
    match = re.fullmatch(r"\$\{[^:}]+:(.*)\}", raw_value.strip())
    if match:
        return match.group(1)
    return raw_value.strip()


def parse_jdbc_url(jdbc_url: str) -> Dict[str, str]:
    match = JDBC_URL_RE.match(jdbc_url.strip())
    if not match:
        return {}
    return {
        "DB_HOST": match.group("host"),
        "DB_PORT": match.group("port") or "3306",
        "DB_NAME": match.group("db"),
    }


def load_fallback_db_env() -> Dict[str, str]:
    merged: Dict[str, str] = {}

    local_env = load_key_value_file(LOCAL_ENV_FILE)
    merged.update({key: value for key, value in local_env.items() if value})

    spring_app = load_key_value_file(SPRING_APP_FILE)
    spring_local = load_key_value_file(SPRING_LOCAL_FILE)

    jdbc_values = parse_jdbc_url(spring_app.get("spring.datasource.url", ""))
    for key, value in jdbc_values.items():
        merged.setdefault(key, value)

    username_value = spring_local.get("DB_USERNAME") or extract_default_placeholder(
        spring_app.get("spring.datasource.username", "")
    )
    password_value = spring_local.get("DB_PASSWORD") or extract_default_placeholder(
        spring_app.get("spring.datasource.password", "")
    )

    if username_value:
        merged.setdefault("DB_USER", username_value)
    if password_value or "DB_PASSWORD" in spring_local or "spring.datasource.password" in spring_app:
        merged.setdefault("DB_PASSWORD", password_value)

    return merged


def get_db_config() -> Dict[str, Any]:
    env_map = {
        "host": "DB_HOST",
        "port": "DB_PORT",
        "database": "DB_NAME",
        "user": "DB_USER",
        "password": "DB_PASSWORD",
    }
    fallback_env = load_fallback_db_env()
    for env_name, env_value in fallback_env.items():
        os.environ.setdefault(env_name, env_value)

    missing = [env_name for env_name in env_map.values() if not os.getenv(env_name)]
    if missing:
        raise ReadOnlyDbError("Missing database environment variables: " + ", ".join(missing))

    port_raw = os.getenv("DB_PORT", "").strip()
    try:
        port = int(port_raw)
    except ValueError as exc:
        raise ReadOnlyDbError("DB_PORT must be an integer.") from exc

    return {
        "host": os.getenv("DB_HOST", "").strip(),
        "port": port,
        "database": os.getenv("DB_NAME", "").strip(),
        "user": os.getenv("DB_USER", "").strip(),
        "password": os.getenv("DB_PASSWORD", ""),
    }


def get_pymysql():
    try:
        import pymysql  # type: ignore
        from pymysql.cursors import DictCursor  # type: ignore
    except ImportError as exc:
        raise ReadOnlyDbError("Missing dependency pymysql. Run: pip install pymysql") from exc
    return pymysql, DictCursor


def connect():
    config = get_db_config()
    pymysql, dict_cursor = get_pymysql()
    return pymysql.connect(
        host=config["host"],
        port=config["port"],
        user=config["user"],
        password=config["password"],
        database=config["database"],
        charset="utf8mb4",
        cursorclass=dict_cursor,
        connect_timeout=5,
        read_timeout=10,
        write_timeout=10,
        autocommit=False,
    )


def normalize_row(row: Dict[str, Any]) -> Dict[str, Any]:
    normalized: Dict[str, Any] = {}
    for key, value in row.items():
        normalized[str(key).lower()] = value
    return normalized


def execute_query(sql: str, params: Tuple[Any, ...] = ()) -> List[Dict[str, Any]]:
    connection = connect()
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql, params)
            rows = cursor.fetchall()
            return [normalize_row(row) for row in rows]
    finally:
        connection.close()


def ensure_table_exists(table: str) -> None:
    rows = execute_query(
        """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = %s AND table_name = %s
        """,
        (get_db_config()["database"], table),
    )
    if not rows:
        raise ReadOnlyDbError(f"Table not found: {table}")


def strip_trailing_semicolon(sql: str) -> str:
    stripped = sql.strip()
    if stripped.endswith(";"):
        stripped = stripped[:-1].rstrip()
    if ";" in stripped:
        raise ReadOnlyDbError("Only one SQL statement is allowed.")
    return stripped


def validate_comments(sql: str) -> None:
    if "--" in sql or "/*" in sql or "*/" in sql or "#" in sql:
        raise ReadOnlyDbError("SQL comments are not allowed.")


def normalize_select_sql(raw_sql: str) -> str:
    sql = strip_trailing_semicolon(raw_sql)
    if not sql:
        raise ReadOnlyDbError("SQL cannot be empty.")

    validate_comments(sql)

    if not re.match(r"^\s*select\b", sql, re.IGNORECASE):
        raise ReadOnlyDbError("Only SELECT statements are allowed.")

    if FORBIDDEN_SQL_RE.search(sql):
        raise ReadOnlyDbError("Dangerous SQL keyword detected. Query rejected.")

    if LOCKING_SELECT_RE.search(sql):
        raise ReadOnlyDbError("Locking SELECT statements are not allowed.")

    limit_match = LIMIT_AT_END_RE.search(sql)
    if limit_match:
        if limit_match.group("second") is not None:
            row_count = int(limit_match.group("second"))
        else:
            row_count = int(limit_match.group("first"))
        if row_count > MAX_SAMPLE_LIMIT:
            raise ReadOnlyDbError(f"SQL LIMIT cannot exceed {MAX_SAMPLE_LIMIT}.")
        return sql

    return f"{sql} LIMIT {DEFAULT_SQL_LIMIT}"


def handle_tables() -> None:
    config = get_db_config()
    rows = execute_query(
        """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = %s
        ORDER BY table_name
        """,
        (config["database"],),
    )
    tables = [row["table_name"] for row in rows]
    json_print(
        success_payload(
            command="tables",
            data=tables,
            database=config["database"],
            count=len(tables),
        )
    )


def handle_schema(table: str) -> None:
    table = require_table_name(table)
    ensure_table_exists(table)
    config = get_db_config()
    rows = execute_query(
        """
        SELECT
            column_name,
            ordinal_position,
            column_type,
            data_type,
            is_nullable,
            column_default,
            column_key,
            extra,
            column_comment
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
        """,
        (config["database"], table),
    )
    json_print(
        success_payload(
            command="schema",
            data=rows,
            database=config["database"],
            table=table,
            count=len(rows),
        )
    )


def parse_sample_limit(limit: Optional[str]) -> int:
    if limit is None:
        return DEFAULT_SAMPLE_LIMIT
    try:
        parsed = int(limit)
    except ValueError as exc:
        raise ReadOnlyDbError("limit must be an integer.") from exc
    if parsed <= 0:
        raise ReadOnlyDbError("limit must be greater than 0.")
    if parsed > MAX_SAMPLE_LIMIT:
        raise ReadOnlyDbError(f"limit cannot exceed {MAX_SAMPLE_LIMIT}.")
    return parsed


def handle_sample(table: str, limit: Optional[str]) -> None:
    table = require_table_name(table)
    row_limit = parse_sample_limit(limit)
    ensure_table_exists(table)
    rows = execute_query(f"SELECT * FROM `{table}` LIMIT %s", (row_limit,))
    json_print(
        success_payload(
            command="sample",
            data=rows,
            table=table,
            limit=row_limit,
            count=len(rows),
        )
    )


def handle_sql(raw_sql: str) -> None:
    sql = normalize_select_sql(raw_sql)
    rows = execute_query(sql)
    json_print(
        success_payload(
            command="sql",
            data=rows,
            sql=sql,
            count=len(rows),
        )
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Read-only MySQL inspector. Only SELECT queries are allowed."
    )
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("tables", help="List all tables in the current database")

    schema_parser = subparsers.add_parser("schema", help="Show table schema")
    schema_parser.add_argument("table", help="Table name")

    sample_parser = subparsers.add_parser("sample", help="Show sample rows")
    sample_parser.add_argument("table", help="Table name")
    sample_parser.add_argument("limit", nargs="?", help="Row limit, default 10, max 50")

    sql_parser = subparsers.add_parser("sql", help="Execute one read-only SELECT query")
    sql_parser.add_argument("query", help='A single SELECT statement, e.g. "SELECT * FROM x_user"')

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        raise SystemExit(1)

    try:
        if args.command == "tables":
            handle_tables()
        elif args.command == "schema":
            handle_schema(args.table)
        elif args.command == "sample":
            handle_sample(args.table, args.limit)
        elif args.command == "sql":
            handle_sql(args.query)
        else:
            raise ReadOnlyDbError(f"Unsupported command: {args.command}")
    except ReadOnlyDbError as exc:
        json_print(
            error_payload(
                error_type="readonly_validation_error",
                message=str(exc),
                command=args.command,
            ),
            exit_code=1,
        )
    except Exception as exc:  # pragma: no cover - defensive fallback
        json_print(
            error_payload(
                error_type=exc.__class__.__name__,
                message=str(exc),
                command=args.command,
            ),
            exit_code=1,
        )


if __name__ == "__main__":
    main()
