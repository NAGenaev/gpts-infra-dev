-- Генерация тестовых данных для нагрузочного тестирования GPTS
-- Использование: psql -h localhost -U gpts -d gpts -f scripts/generate-test-data.sql

-- Генерация тестовых пользователей и счетов
DO $$
DECLARE
    i INTEGER;
    v_user_id BIGINT;
    phone_number VARCHAR;
    email_address VARCHAR;
    account_number VARCHAR;
    product_master_id UUID;
    account_unit_id UUID;
    current_period VARCHAR;
    v_current_time TIMESTAMP;
BEGIN
    -- Генерируем 1000 пользователей
    FOR i IN 1..1000 LOOP
        v_user_id := 100000 + i;
        phone_number := '+7999' || LPAD(i::TEXT, 7, '0');
        email_address := 'testuser' || v_user_id || '@test.gpts.local';
        current_period := TO_CHAR(NOW(), 'YYYY-MM');
        v_current_time := NOW();
        account_number := '4' || LPAD(i::TEXT, 19, '0');
        product_master_id := gen_random_uuid();
        account_unit_id := gen_random_uuid();
        
        -- Создаем пользователя
        INSERT INTO gpts_users.users (
            user_id, 
            email,
            password,
            role,
            full_name,
            phone
        ) VALUES (
            v_user_id,
            email_address,
            '$2a$10$MK5XEdATsZ47Av9yjSLd9OCfkRxLxmmxTlP3HbOovO3RfW2PX7OYK', -- password hash из примера
            'ROLE_USER',
            'Тестовый Пользователь ' || i,
            phone_number
        ) ON CONFLICT (user_id) DO NOTHING;
        
        -- Создаем Product Master (только если еще не существует продукт для этого пользователя)
        INSERT INTO gpts_account_product.product_master (
            id,
            status,
            product_master_number,
            effective_date,
            usr_id_owner,
            usr_id_owner_system,
            product_type_id,
            branch_code,
            service_point,
            dogovor_id,
            created_at,
            updated_at
        )
        SELECT 
            product_master_id,
            'ACTIVE',
            account_number,
            v_current_time,
            v_user_id,
            'GPTS',
            1, -- product_type_id
            '001', -- branch_code
            'SP001', -- service_point
            0, -- dogovor_id
            v_current_time,
            v_current_time
        WHERE NOT EXISTS (
            SELECT 1 
            FROM gpts_account_product.product_master 
            WHERE usr_id_owner = v_user_id 
              AND status = 'ACTIVE'
        );
        
        -- Получаем ID созданного Product Master
        SELECT id INTO product_master_id
        FROM gpts_account_product.product_master
        WHERE usr_id_owner = v_user_id 
          AND status = 'ACTIVE'
        LIMIT 1;
        
        -- Создаем Account Unit (только если еще не существует счет с таким номером)
        INSERT INTO gpts_account_product.account_units (
            id,
            product_master_id,
            status,
            acc_number,
            acc_global_id,
            unit_type,
            start_date,
            currency,
            created_at,
            updated_at
        )
        SELECT 
            account_unit_id,
            product_master_id,
            'ACTIVE',
            account_number,
            gen_random_uuid(),
            'MAIN',
            v_current_time,
            'RUB',
            v_current_time,
            v_current_time
        WHERE product_master_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1 
            FROM gpts_account_product.account_units 
            WHERE acc_number = account_number
          );
        
        -- Получаем ID созданного Account Unit
        SELECT id INTO account_unit_id
        FROM gpts_account_product.account_units
        WHERE acc_number = account_number
        LIMIT 1;
        
        -- Создаем балансы (только если account_unit_id существует)
        IF account_unit_id IS NOT NULL THEN
            INSERT INTO gpts_account_product.account_unit_values (
                id,
                unit_id,
                product_id,
                type,
                value,
                business_day,
                calculation_time,
                record_status,
                created_at,
                updated_at
            )
            SELECT 
                gen_random_uuid(),
                account_unit_id,
                product_master_id,
                'AVAILABLE',
                1000000.00, -- 1 млн рублей
                v_current_time,
                v_current_time,
                'ACTIVE',
                v_current_time,
                v_current_time
            WHERE NOT EXISTS (
                SELECT 1 
                FROM gpts_account_product.account_unit_values 
                WHERE unit_id = account_unit_id 
                  AND type = 'AVAILABLE'
            );
            
            INSERT INTO gpts_account_product.account_unit_values (
                id,
                unit_id,
                product_id,
                type,
                value,
                business_day,
                calculation_time,
                record_status,
                created_at,
                updated_at
            )
            SELECT 
                gen_random_uuid(),
                account_unit_id,
                product_master_id,
                'CURRENT',
                1000000.00,
                v_current_time,
                v_current_time,
                'ACTIVE',
                v_current_time,
                v_current_time
            WHERE NOT EXISTS (
                SELECT 1 
                FROM gpts_account_product.account_unit_values 
                WHERE unit_id = account_unit_id 
                  AND type = 'CURRENT'
            );
        END IF;
        
        -- Создаем лимит (если еще не существует)
        INSERT INTO gpts_limit_fee.monthly_limits (
            period,
            used_amount,
            user_id
        ) 
        SELECT 
            current_period,
            0.00,
            v_user_id
        WHERE NOT EXISTS (
            SELECT 1 
            FROM gpts_limit_fee.monthly_limits 
            WHERE user_id = v_user_id AND period = current_period
        );
        
    END LOOP;
    
    RAISE NOTICE 'Сгенерировано 1000 пользователей со счетами';
END $$;

-- Проверка данных
SELECT 
    'Пользователи' as "Тип данных",
    COUNT(*) as "Количество"
FROM gpts_users.users 
WHERE user_id >= 100000
UNION ALL
SELECT 
    'Счета' as "Тип данных",
    COUNT(*) as "Количество"
FROM gpts_account_product.account_units
UNION ALL
SELECT 
    'Балансы' as "Тип данных",
    COUNT(*) as "Количество"
FROM gpts_account_product.account_unit_values
UNION ALL
SELECT 
    'Лимиты' as "Тип данных",
    COUNT(*) as "Количество"
FROM gpts_limit_fee.monthly_limits;





-- Генерация CSV файла с тестовыми данными для JMeter
-- Использование: 
--   docker exec -i c5fa405b04c4 psql -U gpts -d gpts -A -F',' -t < scripts/generate-csv-data.sql | sed '1i userId,email,phone,accountNumber' > test-users.csv
--   или проще:
--   docker exec -i c5fa405b04c4 psql -U gpts -d gpts -c "COPY (SELECT u.user_id as userId, u.email, u.phone, au.acc_number as accountNumber FROM gpts_users.users u JOIN gpts_account_product.product_master pm ON u.user_id = pm.usr_id_owner JOIN gpts_account_product.account_units au ON pm.id = au.product_master_id WHERE u.user_id >= 100000 AND au.status = 'ACTIVE' ORDER BY u.user_id LIMIT 1000) TO STDOUT WITH CSV HEADER" > test-users.csv

SELECT 
    u.user_id as userId,
    u.full_name,
    pm.id as productId,
    au.id as accountUnitId,
    au.acc_number as accountNumber
FROM gpts_users.users u
JOIN gpts_account_product.product_master pm ON u.user_id = pm.usr_id_owner
JOIN gpts_account_product.account_units au ON pm.id = au.product_master_id
WHERE u.user_id >= 100000
  AND au.status = 'ACTIVE'
ORDER BY u.user_id
LIMIT 1000;


--переводы статусы
select a.status, count(*) from gpts_transfer_orchestrator.transfersv2 a group by a.status;

--шаги саги статусы
select s.status, count(*) from gpts_transfer_orchestrator.saga_step_status s group by s.status;

--шаги саги статусы в разрезе шагов
select s.step_name ,s.status, count(*) from gpts_transfer_orchestrator.saga_step_status s group by s.step_name, s.status;

--ошибочные шаги саги
select * from gpts_transfer_orchestrator.saga_step_status s where status != 'COMPLETED';

--статусы евенотов 
select s.application_system, s.event_type, s.description, s.status, count(*) from gpts_account_product."event" s group by s.application_system, s.event_type, s.description, s.status;

--статусы операций 
select s.system, s.direction, s.status, count(*) from gpts_account_product.operations s group by s.system, s.direction, s.status;

--балансы
select * from gpts_account_product.account_unit_values order by value;

--очистка таблиц
TRUNCATE TABLE gpts_fraud.fraud_transactions;
TRUNCATE TABLE gpts_fraud.fraud_statistics;
TRUNCATE table gpts_account_product."event";
TRUNCATE table gpts_account_product.operations;
TRUNCATE TABLE gpts_transfer_orchestrator.transfersv2 CASCADE;
TRUNCATE TABLE gpts_transfer_orchestrator.saga_step_status CASCADE;
TRUNCATE TABLE gpts_transfer_history.transfer_history;
TRUNCATE TABLE gpts_limit_fee.commissions;
TRUNCATE TABLE gpts_account_product."event";
TRUNCATE TABLE gpts_account_product.operations;
--сброс лимитов
UPDATE gpts_limit_fee.monthly_limits SET "period"='2025-12', used_amount=0;
--сброс рейтингов
UPDATE gpts_fraud.user_rating SET rating=100, last_updated='2025-12-15 10:15:00.691', "blocked"=false;




-- reset_test_env.sql --очистка таблиц через plsql
DO $$
BEGIN
    RAISE NOTICE 'Starting test environment reset...';
    -- Очистка
    TRUNCATE TABLE 
        gpts_fraud.fraud_transactions,
        gpts_fraud.fraud_statistics,
        gpts_account_product."event",
        gpts_account_product.operations,
        gpts_transfer_history.transfer_history,
        gpts_limit_fee.commissions;
    TRUNCATE TABLE gpts_transfer_orchestrator.saga_step_status CASCADE;
    TRUNCATE TABLE gpts_transfer_orchestrator.transfersv2 CASCADE;
	-- Сброс балансов
    UPDATE gpts_account_product.account_unit_values SET value=100000000;
    -- Сброс лимитов
    UPDATE gpts_limit_fee.monthly_limits SET "period" = '2025-12', used_amount = 0;
    -- Сброс рейтингов
    UPDATE gpts_fraud.user_rating SET rating = 100, last_updated = NOW(), blocked = false;
    RAISE NOTICE 'Test environment reset completed!';
END $$;


SELECT pg_stat_reset();
SELECT 
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_tup_read + idx_tup_fetch DESC
LIMIT 10;


VACUUM (FULL, VERBOSE, ANALYZE) gpts_transfer_orchestrator.transfersv2;
VACUUM (FULL, VERBOSE, ANALYZE) gpts_transfer_orchestrator.saga_step_status;
VACUUM (FULL, VERBOSE, ANALYZE) gpts_fraud.fraud_transactions;
VACUUM (FULL, VERBOSE, ANALYZE) gpts_fraud.fraud_statistics;
VACUUM (FULL, VERBOSE, ANALYZE) gpts_account_product."event";
VACUUM (FULL, VERBOSE, ANALYZE) gpts_account_product.operations;
VACUUM (FULL, VERBOSE, ANALYZE) gpts_transfer_history.transfer_history;
VACUUM (FULL, VERBOSE, ANALYZE) gpts_limit_fee.commissions;

ANALYZE gpts_transfer_orchestrator.transfersv2;
ANALYZE gpts_transfer_orchestrator.saga_step_status;
ANALYZE gpts_fraud.fraud_transactions;
ANALYZE gpts_fraud.fraud_statistics;
ANALYZE gpts_account_product."event";
ANALYZE gpts_account_product.operations;
ANALYZE gpts_transfer_history.transfer_history;
ANALYZE gpts_limit_fee.commissions;


-- Проверить создание
SELECT schemaname, tablename, indexname 
FROM pg_indexes 
WHERE tablename IN ('saga_step_status', 'transfersv2')
ORDER BY tablename, indexname;
EOF

SELECT 
    datname,
    count(*) as total_connections,
    count(*) FILTER (WHERE state != 'idle') as active_connections,
    count(*) FILTER (WHERE state = 'idle' AND now() - state_change > interval '5 minutes') as stale_connections
FROM pg_stat_activity 
GROUP BY datname
ORDER BY total_connections DESC;
