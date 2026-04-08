-- Username unique-constraint fix script (MySQL 8+).
-- Backup database before running this script.

-- 1) Find duplicated usernames (including logically deleted rows).
SELECT username, COUNT(*) AS cnt
FROM x_user
GROUP BY username
HAVING COUNT(*) > 1;

-- 2) Check duplicated row details.
SELECT id, username, deleted, status, email, phone, name
FROM x_user
WHERE username IN (
    SELECT username
    FROM x_user
    GROUP BY username
    HAVING COUNT(*) > 1
)
ORDER BY username, deleted ASC, id ASC;

-- 3) Backup duplicated rows (optional but strongly recommended).
CREATE TABLE IF NOT EXISTS x_user_dup_backup LIKE x_user;
INSERT INTO x_user_dup_backup
SELECT *
FROM x_user
WHERE username IN (
    SELECT username
    FROM (
        SELECT username
        FROM x_user
        GROUP BY username
        HAVING COUNT(*) > 1
    ) t
);

-- Read real max length of x_user.username to avoid overflow when renaming duplicates.
SET @username_len := (
    SELECT COALESCE(CHARACTER_MAXIMUM_LENGTH, 50)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'x_user'
      AND column_name = 'username'
    LIMIT 1
);

-- 4) Keep one row per username (prefer deleted=0, then smallest id).
--    Rename other duplicates and mark them as logically deleted.
UPDATE x_user u
JOIN (
    SELECT username,
           COALESCE(MIN(CASE WHEN deleted = 0 THEN id END), MIN(id)) AS keep_id
    FROM x_user
    GROUP BY username
    HAVING COUNT(*) > 1
) d ON u.username = d.username
SET u.username = CONCAT(
        LEFT(
            u.username,
            GREATEST(@username_len - CHAR_LENGTH(CONCAT('__dup_', u.id)), 0)
        ),
        '__dup_', u.id
    ),
    u.deleted = 1
WHERE u.id <> d.keep_id;

-- 5) Recheck duplicates.
SELECT username, COUNT(*) AS cnt
FROM x_user
GROUP BY username
HAVING COUNT(*) > 1;

-- 6) Add global unique index on username (idempotent).
--    Detect any UNIQUE index that is exactly one column: username (index name can be different).
SET @idx_exists := (
    SELECT COUNT(1)
    FROM (
        SELECT s.index_name,
               COUNT(*) AS total_col_cnt,
               SUM(CASE WHEN s.column_name = 'username' THEN 1 ELSE 0 END) AS username_col_cnt,
               MIN(s.non_unique) AS non_unique
        FROM information_schema.statistics s
        WHERE s.table_schema = DATABASE()
          AND s.table_name = 'x_user'
        GROUP BY s.index_name
    ) idx
    WHERE idx.non_unique = 0
      AND idx.total_col_cnt = 1
      AND idx.username_col_cnt = 1
);
SET @ddl := IF(
    @idx_exists = 0,
    'ALTER TABLE x_user ADD UNIQUE INDEX uk_x_user_username (username)',
    'SELECT ''uk_x_user_username already exists'' AS msg'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 7) Verify UNIQUE index on username (regardless of index name).
SELECT index_name,
       MIN(non_unique) AS non_unique,
       COUNT(*) AS col_cnt,
       SUM(CASE WHEN column_name = 'username' THEN 1 ELSE 0 END) AS username_col_cnt
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND table_name = 'x_user'
GROUP BY index_name
HAVING non_unique = 0
   AND col_cnt = 1
   AND username_col_cnt = 1;
