-- схемы
CREATE SCHEMA IF NOT EXISTS gpts_account_product_sub;
CREATE SCHEMA IF NOT EXISTS gpts_account_product;
CREATE SCHEMA IF NOT EXISTS gpts_sanctions;
CREATE SCHEMA IF NOT EXISTS gpts_fraud;
CREATE SCHEMA IF NOT EXISTS gpts_transfer_orchestrator;


-- пользователи
CREATE USER gpts_worker_sub WITH PASSWORD 'sub_pass';
CREATE USER gpts_worker_master WITH PASSWORD 'master_pass';
CREATE USER gpts_worker_sanctions WITH PASSWORD 'sanctions_pass';
CREATE USER gpts_worker_fraud WITH PASSWORD 'fraud_pass';
CREATE USER gpts_worker_orchestrator WITH PASSWORD 'orchestrator_pass';

-- права на схемы
GRANT ALL ON SCHEMA gpts_account_product_sub TO gpts_worker_sub;
GRANT ALL ON SCHEMA gpts_account_product TO gpts_worker_master;
GRANT ALL ON SCHEMA gpts_sanctions TO gpts_worker_sanctions;
GRANT ALL ON SCHEMA gpts_fraud TO gpts_worker_fraud;
GRANT ALL ON SCHEMA gpts_transfer_orchestrator TO gpts_worker_orchestrator;

