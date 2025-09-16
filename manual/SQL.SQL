
CREATE SCHEMA IF NOT EXISTS account_blocks_and_sanctions;


-- Блокировки
INSERT INTO account_blocks_and_sanctions.blocks (account_id, block_type, reason, source, is_active, created_at)
VALUES 
('112223', 'ARREST', 'Счет арестован по решению суда 11233/122/35 от 24.08.2025', 'CourtDecision', true, now()),
('112224', 'FRAUD', 'Подозрение на фрод (Статья 115 ФЗ)', 'AntiFraudSystem', true, now()),
('112225', 'T_ARREST', 'Счет заблокирован AntiFraudSystem по подозрению в мошенничестве', 'CourtDecision', true, now()),
('112233', 'T_ARREST', 'Счет заблокирован AntiFraudSystem по подозрению в мошенничестве', 'CourtDecision', true, now()),
-- Блокировки по ID 112223
('112223', 'FRAUD', 'Подозрение на фрод (Статья 115 ФЗ)', 'AntiFraudSystem', true, now()),
('112223', 'T_ARREST', 'Счет заблокирован AntiFraudSystem по подозрению в мошенничестве', 'CourtDecision', true, now()),
-- Блокировки по ID 112233
('112233', 'FRAUD', 'Подозрение на фрод (Статья 115 ФЗ)', 'AntiFraudSystem', true, now()),
('112233', 'ARREST', 'Счет арестован по решению суда 11233/122/35 от 24.08.2025', 'CourtDecision', true, now());


-- Санкции
INSERT INTO account_blocks_and_sanctions.sanctions (account_id, sanction_type, reason, source, is_active, created_at)
VALUES
('112230', 'OFAC', 'Внесен в санкционный список OFAC', 'SanctionService', true, now()),
('112231', 'EU', 'Внесен в санкционный список ЕС', 'SanctionService', true, now()),
('112232', 'UN', 'Внесен в санкционный список ООН', 'Regulator', true, now()),
('112233', 'Internal', 'Внутреннее ограничение операций', 'InternalCompliance', true, now()),
('112234', 'FATF', 'Подозрение на финансирование терроризма', 'FATFMonitor', true, now()),
-- Санкции по ID 112233
('112233', 'OFAC', 'Внесен в санкционный список OFAC', 'SanctionService', true, now()),
('112233', 'EU', 'Внесен в санкционный список ЕС', 'SanctionService', true, now()),
('112233', 'UN', 'Внесен в санкционный список ООН', 'Regulator', true, now()),
('112233', 'FATF', 'Подозрение на финансирование терроризма', 'FATFMonitor', true, now());


truncate table gpts_transfer_orchestrator.transfer_history;
truncate table gpts_transfer_orchestrator.transfer_saga;
truncate table gpts_transfer_orchestrator.transfers;
truncate table gpts_transfer_orchestrator.saga_step_status;
truncate table gpts_transfer_orchestrator.transfersv2;


-- Продукты
INSERT INTO gpts_account_product.product_master
    (id, status, dogovor_id, product_master_number, effective_date, revocation_time, usr_id_owner, usr_id_owner_system, product_id, branch_code, service_point)
VALUES
    (1001, 'ACTIVE', 5001, 'ACC1001', now(), null, 1, 'SYSTEM1', 101, 'BR01', 'SP1');


INSERT INTO gpts_account_product.account_units
    (id, product_master_id, status, unit_type, acc_global_id, acc_number, start_date, end_date, currency)
VALUES
    (2002, 1001, 'ACTIVE', 'MAIN', gen_random_uuid(), '1002002002', now(), null, 'RUB');


INSERT INTO gpts_account_product.account_unit_values
    (id, record_status, product_id, unit_id, type, value, last_operation_id, business_day, calculation_time)
VALUES
    (3003, 'ACTIVE', 1001, 2002, 'AVAILABLE', 10000.00, null, now(), now());


ALTER TABLE gpts_account_product.operations
ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY;


