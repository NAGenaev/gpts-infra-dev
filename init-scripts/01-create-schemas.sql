-- схемы
CREATE SCHEMA IF NOT EXISTS gpts_account_product_sub;
CREATE SCHEMA IF NOT EXISTS gpts_account_product;
CREATE SCHEMA IF NOT EXISTS gpts_sanctions;
CREATE SCHEMA IF NOT EXISTS gpts_fraud;
CREATE SCHEMA IF NOT EXISTS gpts_transfer_orchestrator;
CREATE SCHEMA IF NOT EXISTS account_blocks_and_sanctions;
CREATE SCHEMA IF NOT EXISTS gpts_limit_fee;
CREATE SCHEMA IF NOT EXISTS gpts_users;
CREATE SCHEMA IF NOT EXISTS gpts_transfer_history;
CREATE SCHEMA IF NOT EXISTS gpts_operation_history;

-- пользователи
CREATE USER gpts_worker_sub WITH PASSWORD 'sub_pass';
CREATE USER gpts_worker_master WITH PASSWORD 'master_pass';
CREATE USER gpts_worker_sanctions WITH PASSWORD 'sanctions_pass';
CREATE USER gpts_worker_fraud WITH PASSWORD 'fraud_pass';
CREATE USER gpts_worker_orchestrator WITH PASSWORD 'orchestrator_pass';
CREATE USER gpts_worker_limits_fee WITH PASSWORD 'limits_fee_pass';
CREATE USER gpts_worker_history WITH PASSWORD 'history_pass';
CREATE USER gpts_worker_users WITH PASSWORD 'users_pass';

-- права на схемы
GRANT ALL ON SCHEMA gpts_account_product_sub TO gpts_worker_sub;
GRANT ALL ON SCHEMA gpts_account_product TO gpts_worker_master;
GRANT ALL ON SCHEMA gpts_sanctions TO gpts_worker_sanctions;
GRANT ALL ON SCHEMA gpts_fraud TO gpts_worker_fraud;
GRANT ALL ON SCHEMA gpts_transfer_orchestrator TO gpts_worker_orchestrator;
GRANT ALL ON SCHEMA gpts_operation_history TO gpts_worker_history;
GRANT ALL ON SCHEMA gpts_users TO gpts_worker_users;
GRANT ALL ON SCHEMA gpts_transfer_history TO gpts_worker_history;
GRANT ALL ON SCHEMA gpts_limit_fee TO gpts_worker_limits_fee;
GRANT ALL ON SCHEMA account_blocks_and_sanctions TO gpts_worker_sanctions;