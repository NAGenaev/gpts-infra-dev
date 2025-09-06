-- схемы
CREATE SCHEMA IF NOT EXISTS gpts_account_product_sub;
CREATE SCHEMA IF NOT EXISTS gpts_account_product;
CREATE SCHEMA IF NOT EXISTS gpts_sanctions;

-- пользователи
CREATE USER gpts_worker_sub WITH PASSWORD 'sub_pass';
CREATE USER gpts_worker_master WITH PASSWORD 'master_pass';
CREATE USER gpts_worker_sanctions WITH PASSWORD 'sanctions_pass';

-- права на схемы
GRANT ALL ON SCHEMA gpts_account_product_sub TO gpts_worker_sub;
GRANT ALL ON SCHEMA gpts_account_product TO gpts_worker_master;
GRANT ALL ON SCHEMA gpts_sanctions TO gpts_worker_sanctions;

