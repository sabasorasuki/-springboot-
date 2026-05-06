-- Run this only after the XGBoost LTR recommendation endpoint is online and verified.
-- It keeps a backup table before dropping the legacy collaborative-filtering table.

CREATE TABLE IF NOT EXISTS user_article_operation_backup_before_ltr AS
SELECT *
FROM user_article_operation;

DROP TABLE IF EXISTS user_article_operation;
