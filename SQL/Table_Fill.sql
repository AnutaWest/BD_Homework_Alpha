USE BankCashOrders;
GO

-- 1. ЗАПОЛНЕНИЕ СПРАВОЧНИКОВ
INSERT INTO departments (name, address, phone, email) VALUES
('Центральное отделение', 'ул. Ленина, 1, Москва', '+7 (495) 123-45-67', 'central@bank.ru'),
('Северное отделение', 'пр. Гагарина, 10, Санкт-Петербург', '+7 (812) 234-56-78', 'north@bank.ru'),
('Южное отделение', 'ул. Пушкина, 25, Краснодар', '+7 (861) 345-67-89', 'south@bank.ru'),
('Западное отделение', 'пр. Мира, 5, Калининград', '+7 (401) 456-78-90', 'west@bank.ru'),
('Восточное отделение', 'ул. Лермонтова, 15, Владивосток', '+7 (423) 567-89-01', 'east@bank.ru');
GO

INSERT INTO request_statuses (status_name, description) VALUES
('Новая', 'Заявка создана, ожидает назначения сотрудника'),
('Назначена', 'Назначен ответственный сотрудник'),
('Выдана', 'Наличные выданы клиенту'),
('Отменена', 'Заявка отменена клиентом'),
('Просрочена', 'Истек срок действия заявки'),
('Ожидает пополнения', 'Недостаточно средств на счете');
GO

-- 2. ГЕНЕРАЦИЯ СЛУЧАЙНЫХ СОТРУДНИКОВ
DECLARE @department_id INT;
DECLARE @dept_cursor CURSOR;
DECLARE @emp_count INT;
DECLARE @i INT;
DECLARE @last_name NVARCHAR(100);
DECLARE @first_name NVARCHAR(100);
DECLARE @position NVARCHAR(100);
DECLARE @is_head BIT;

DECLARE @last_names TABLE (id INT, name NVARCHAR(100));
INSERT INTO @last_names VALUES 
(1, 'Иванов'), (2, 'Петров'), (3, 'Сидоров'), (4, 'Смирнов'), (5, 'Кузнецов'),
(6, 'Попов'), (7, 'Васильев'), (8, 'Михайлов'), (9, 'Федоров'), (10, 'Морозов'),
(11, 'Волков'), (12, 'Алексеев'), (13, 'Лебедев'), (14, 'Семенов'), (15, 'Егоров'),
(16, 'Павлов'), (17, 'Козлов'), (18, 'Степанов'), (19, 'Николаев'), (20, 'Орлов');

DECLARE @first_names TABLE (id INT, name NVARCHAR(100));
INSERT INTO @first_names VALUES 
(1, 'Александр'), (2, 'Дмитрий'), (3, 'Максим'), (4, 'Сергей'), (5, 'Андрей'),
(6, 'Алексей'), (7, 'Артем'), (8, 'Илья'), (9, 'Кирилл'), (10, 'Михаил'),
(11, 'Никита'), (12, 'Егор'), (13, 'Матвей'), (14, 'Роман'), (15, 'Владимир'),
(16, 'Анна'), (17, 'Мария'), (18, 'Елена'), (19, 'Ольга'), (20, 'Наталья');

SET @dept_cursor = CURSOR FOR SELECT department_id FROM departments;
OPEN @dept_cursor;
FETCH NEXT FROM @dept_cursor INTO @department_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @emp_count = 3 + CAST(RAND(CHECKSUM(NEWID())) * 6 AS INT);
    
    SET @is_head = 1;
    SELECT TOP 1 @last_name = name FROM @last_names ORDER BY NEWID();
    SELECT TOP 1 @first_name = name FROM @first_names ORDER BY NEWID();
    SET @position = CASE ABS(CHECKSUM(NEWID()) % 3)
        WHEN 0 THEN 'Начальник отделения'
        WHEN 1 THEN 'Управляющий'
        ELSE 'Директор'
    END;
    
    INSERT INTO employees (department_id, last_name, first_name, middle_name, position, is_head, phone, email)
    VALUES (
        @department_id,
        @last_name,
        @first_name,
        CASE ABS(CHECKSUM(NEWID()) % 3) WHEN 0 THEN 'Иванович' WHEN 1 THEN 'Петрович' ELSE 'Сергеевич' END,
        @position,
        @is_head,
        '+7 (' + CAST(900 + @department_id * 10 AS NVARCHAR) + ') ' + 
        CAST(100 + CAST(RAND(CHECKSUM(NEWID())) * 899 AS INT) AS NVARCHAR) + '-' +
        CAST(10 + CAST(RAND(CHECKSUM(NEWID())) * 89 AS INT) AS NVARCHAR) + '-' +
        CAST(10 + CAST(RAND(CHECKSUM(NEWID())) * 89 AS INT) AS NVARCHAR),
        @last_name + '.' + @first_name + '@bank.ru'
    );
    
    SET @i = 2;
    WHILE @i <= @emp_count
    BEGIN
        SET @is_head = 0;
        SELECT TOP 1 @last_name = name FROM @last_names ORDER BY NEWID();
        SELECT TOP 1 @first_name = name FROM @first_names ORDER BY NEWID();
        SET @position = CASE ABS(CHECKSUM(NEWID()) % 5)
            WHEN 0 THEN 'Кассир'
            WHEN 1 THEN 'Старший кассир'
            WHEN 2 THEN 'Операционист'
            WHEN 3 THEN 'Специалист'
            ELSE 'Консультант'
        END;
        
        INSERT INTO employees (department_id, last_name, first_name, middle_name, position, is_head, phone, email)
        VALUES (
            @department_id,
            @last_name,
            @first_name,
            CASE ABS(CHECKSUM(NEWID()) % 3) WHEN 0 THEN 'Иванович' WHEN 1 THEN 'Петрович' ELSE 'Сергеевич' END,
            @position,
            @is_head,
            '+7 (' + CAST(900 + @department_id * 10 AS NVARCHAR) + ') ' + 
            CAST(100 + CAST(RAND(CHECKSUM(NEWID())) * 899 AS INT) AS NVARCHAR) + '-' +
            CAST(10 + CAST(RAND(CHECKSUM(NEWID())) * 89 AS INT) AS NVARCHAR) + '-' +
            CAST(10 + CAST(RAND(CHECKSUM(NEWID())) * 89 AS INT) AS NVARCHAR),
            @last_name + '.' + @first_name + '@bank.ru'
        );
        
        SET @i = @i + 1;
    END;
    
    FETCH NEXT FROM @dept_cursor INTO @department_id;
END;

CLOSE @dept_cursor;
DEALLOCATE @dept_cursor;
GO

-- 3. ГЕНЕРАЦИЯ СЛУЧАЙНЫХ КЛИЕНТОВ
DECLARE @client_count INT = 20;
DECLARE @j INT = 1;
DECLARE @last_name NVARCHAR(100);
DECLARE @first_name NVARCHAR(100);
DECLARE @passport_num NVARCHAR(50);

WHILE @j <= @client_count
BEGIN
    SELECT TOP 1 @last_name = name FROM (VALUES 
        ('Смирнов'), ('Иванов'), ('Кузнецов'), ('Попов'), ('Васильев'),
        ('Петров'), ('Соколов'), ('Михайлов'), ('Федоров'), ('Морозов')
    ) AS names(name) ORDER BY NEWID();
    
    SELECT TOP 1 @first_name = name FROM (VALUES 
        ('Александр'), ('Дмитрий'), ('Максим'), ('Сергей'), ('Андрей'),
        ('Алексей'), ('Артем'), ('Илья'), ('Михаил'), ('Владимир'),
        ('Анна'), ('Мария'), ('Елена'), ('Ольга'), ('Татьяна')
    ) AS names(name) ORDER BY NEWID();
    
    SET @passport_num = 
        CAST(4000 + CAST(RAND(CHECKSUM(NEWID())) * 999 AS INT) AS NVARCHAR) + ' ' +
        CAST(100000 + CAST(RAND(CHECKSUM(NEWID())) * 899999 AS INT) AS NVARCHAR);
    
    INSERT INTO clients (last_name, first_name, middle_name, passport_number, phone, email)
    VALUES (
        @last_name,
        @first_name,
        CASE ABS(CHECKSUM(NEWID()) % 3) WHEN 0 THEN 'Иванович' WHEN 1 THEN 'Петрович' ELSE 'Александрович' END,
        @passport_num,
        '+7 (' + CAST(900 + CAST(RAND(CHECKSUM(NEWID())) * 99 AS INT) AS NVARCHAR) + ') ' + 
        CAST(100 + CAST(RAND(CHECKSUM(NEWID())) * 899 AS INT) AS NVARCHAR) + '-' +
        CAST(10 + CAST(RAND(CHECKSUM(NEWID())) * 89 AS INT) AS NVARCHAR) + '-' +
        CAST(10 + CAST(RAND(CHECKSUM(NEWID())) * 89 AS INT) AS NVARCHAR),
        @last_name + '.' + @first_name + '@' + 
        CASE ABS(CHECKSUM(NEWID()) % 3) WHEN 0 THEN 'mail.ru' WHEN 1 THEN 'yandex.ru' ELSE 'gmail.com' END
    );
    
    SET @j = @j + 1;
END;
GO

-- 4. ГЕНЕРАЦИЯ СЧЕТОВ
DECLARE @client_cursor CURSOR;
DECLARE @client_id INT;
DECLARE @account_count INT;
DECLARE @k INT;
DECLARE @currencies TABLE (id INT, code NVARCHAR(10));
INSERT INTO @currencies VALUES (1, 'RUB'), (2, 'USD'), (3, 'EUR');

SET @client_cursor = CURSOR FOR SELECT client_id FROM clients;
OPEN @client_cursor;
FETCH NEXT FROM @client_cursor INTO @client_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @account_count = CASE WHEN RAND(CHECKSUM(NEWID())) < 0.7 THEN 1 ELSE 2 END;
    SET @k = 1;
    
    WHILE @k <= @account_count
    BEGIN
        INSERT INTO accounts (client_id, account_number, currency, opened_date, status)
        VALUES (
            @client_id,
            '40817' + CAST(10000000000 + CAST(RAND(CHECKSUM(NEWID())) * 89999999999 AS BIGINT) AS NVARCHAR),
            (SELECT TOP 1 code FROM @currencies ORDER BY NEWID()),
            DATEADD(day, -CAST(RAND(CHECKSUM(NEWID())) * 1000 AS INT), GETDATE()),
            CASE WHEN RAND(CHECKSUM(NEWID())) < 0.9 THEN 'активен' ELSE 'заблокирован' END
        );
        SET @k = @k + 1;
    END;
    
    FETCH NEXT FROM @client_cursor INTO @client_id;
END;

CLOSE @client_cursor;
DEALLOCATE @client_cursor;
GO

-- 5. ГЕНЕРАЦИЯ ТРАНЗАКЦИЙ
INSERT INTO transactions (account_id, transaction_type, amount, currency, description)
SELECT 
    account_id,
    'зачисление',
    CAST(5000 + RAND(CHECKSUM(NEWID())) * 500000 AS DECIMAL(15,2)),
    currency,
    'Начальный баланс'
FROM accounts;
GO

-- 6. ГЕНЕРАЦИЯ ЗАЯВОК
DECLARE @dept_id INT;
DECLARE @request_cursor CURSOR;
DECLARE @request_per_dept INT;
DECLARE @m INT;
DECLARE @client_id INT;
DECLARE @account_id INT;
DECLARE @employee_id INT;
DECLARE @head_id INT;
DECLARE @status_id INT;
DECLARE @request_date DATETIME;
DECLARE @assigned_date DATETIME;
DECLARE @completion_date DATETIME;
DECLARE @amount DECIMAL(15,2);
DECLARE @currency NVARCHAR(10);
DECLARE @status_name NVARCHAR(50);
DECLARE @months_ago INT;

SET @request_cursor = CURSOR FOR SELECT department_id FROM departments;
OPEN @request_cursor;
FETCH NEXT FROM @request_cursor INTO @dept_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @request_per_dept = 5 + CAST(RAND(CHECKSUM(NEWID())) * 6 AS INT);
    SET @m = 1;
    
    WHILE @m <= @request_per_dept
    BEGIN
        SELECT TOP 1 @client_id = client_id FROM clients ORDER BY NEWID();
        SELECT TOP 1 @account_id = account_id FROM accounts WHERE client_id = @client_id ORDER BY NEWID();
        SELECT @currency = currency FROM accounts WHERE account_id = @account_id;
        SELECT TOP 1 @employee_id = employee_id FROM employees WHERE department_id = @dept_id ORDER BY NEWID();
        SELECT TOP 1 @head_id = employee_id FROM employees WHERE department_id = @dept_id AND is_head = 1;
        
        SET @months_ago = CAST(RAND(CHECKSUM(NEWID())) * 6 AS INT);
        SET @request_date = DATEADD(month, -@months_ago, GETDATE());
        SET @request_date = DATEADD(day, -CAST(RAND(CHECKSUM(NEWID())) * 28 AS INT), @request_date);
        SET @request_date = DATEADD(hour, CAST(RAND(CHECKSUM(NEWID())) * 12 AS INT), @request_date);
        
        SELECT TOP 1 @status_id = request_status_id, @status_name = status_name 
        FROM request_statuses ORDER BY NEWID();
        
        SET @amount = 1000 + CAST(RAND(CHECKSUM(NEWID())) * 499000 AS DECIMAL(15,2));
        
        INSERT INTO requests (
            client_id, department_id, account_id, created_by, assigned_to, 
            status_id, request_date, assigned_date, completion_date, 
            amount, currency, commission, expiration_date, comments
        )
        VALUES (
            @client_id,
            @dept_id,
            @account_id,
            @employee_id,
            CASE 
                WHEN @status_name IN ('Назначена', 'Выдана') THEN @head_id
                WHEN @status_name = 'Новая' THEN NULL
                WHEN RAND(CHECKSUM(NEWID())) < 0.3 THEN @head_id
                ELSE NULL
            END,
            @status_id,
            @request_date,
            CASE 
                WHEN @status_name IN ('Назначена', 'Выдана') THEN DATEADD(hour, 1 + CAST(RAND(CHECKSUM(NEWID())) * 5 AS INT), @request_date)
                ELSE NULL
            END,
            CASE 
                WHEN @status_name = 'Выдана' THEN DATEADD(day, 1 + CAST(RAND(CHECKSUM(NEWID())) * 3 AS INT), @request_date)
                ELSE NULL
            END,
            @amount,
            @currency,
            @amount * 0.01,
            CASE 
                WHEN @status_name IN ('Новая', 'Назначена') THEN DATEADD(day, 7, @request_date)
                ELSE NULL
            END,
            CASE ABS(CHECKSUM(NEWID()) % 4)
                WHEN 0 THEN 'Заявка на снятие наличных'
                WHEN 1 THEN 'Срочное снятие'
                WHEN 2 THEN 'На подарок'
                ELSE 'Обычная заявка'
            END
        );
        
        SET @m = @m + 1;
    END;
    
    FETCH NEXT FROM @request_cursor INTO @dept_id;
END;

CLOSE @request_cursor;
DEALLOCATE @request_cursor;
GO

-- 7. ГЕНЕРАЦИЯ ТРАНЗАКЦИЙ ПО ЗАЯВКАМ
INSERT INTO transactions (account_id, request_id, transaction_type, amount, currency, transaction_date, description)
SELECT 
    r.account_id,
    r.request_id,
    'блокировка',
    r.amount,
    r.currency,
    DATEADD(minute, 5, r.request_date),
    'Блокировка средств по заявке #' + CAST(r.request_id AS NVARCHAR)
FROM requests r
WHERE r.status_id != (SELECT request_status_id FROM request_statuses WHERE status_name = 'Отменена');

INSERT INTO transactions (account_id, request_id, transaction_type, amount, currency, transaction_date, description)
SELECT 
    r.account_id,
    r.request_id,
    'списание',
    r.amount,
    r.currency,
    r.completion_date,
    'Списание средств по заявке #' + CAST(r.request_id AS NVARCHAR)
FROM requests r
WHERE r.status_id = (SELECT request_status_id FROM request_statuses WHERE status_name = 'Выдана');

INSERT INTO transactions (account_id, request_id, transaction_type, amount, currency, transaction_date, description)
SELECT 
    r.account_id,
    r.request_id,
    'разблокировка',
    r.amount,
    r.currency,
    CASE 
        WHEN r.status_id = (SELECT request_status_id FROM request_statuses WHERE status_name = 'Отменена') 
            THEN DATEADD(day, 1, r.request_date)
        ELSE DATEADD(day, 8, r.request_date)
    END,
    'Разблокировка по заявке #' + CAST(r.request_id AS NVARCHAR)
FROM requests r
WHERE r.status_id IN (
    (SELECT request_status_id FROM request_statuses WHERE status_name = 'Отменена'),
    (SELECT request_status_id FROM request_statuses WHERE status_name = 'Просрочена')
);
GO

-- 8. ГЕНЕРАЦИЯ ИСТОРИИ СТАТУСОВ
INSERT INTO request_status_history (request_id, status_id, changed_by, changed_at, reason)
SELECT 
    r.request_id,
    r.status_id,
    r.created_by,
    r.request_date,
    'Заявка создана'
FROM requests r
UNION ALL
SELECT 
    r.request_id,
    rs.request_status_id,
    r.assigned_to,
    r.assigned_date,
    'Назначен сотрудник'
FROM requests r
CROSS JOIN request_statuses rs
WHERE rs.status_name = 'Назначена'
AND r.assigned_date IS NOT NULL
UNION ALL
SELECT 
    r.request_id,
    rs.request_status_id,
    r.assigned_to,
    r.completion_date,
    'Наличные выданы клиенту'
FROM requests r
CROSS JOIN request_statuses rs
WHERE rs.status_name = 'Выдана'
AND r.completion_date IS NOT NULL;
GO

-- 9. УВЕДОМЛЕНИЯ
-- Уведомления клиентам
INSERT INTO notifications (client_id, notification_type, subject, content, sent_at)
SELECT 
    r.client_id,
    CASE ABS(CHECKSUM(NEWID()) % 2) WHEN 0 THEN 'sms' ELSE 'email' END,
    'Статус заявки #' + CAST(r.request_id AS NVARCHAR),
    'Ваша заявка на сумму ' + CAST(r.amount AS NVARCHAR) + ' ' + r.currency + ' находится в статусе: ' + rs.status_name,
    CASE 
        WHEN r.request_date IS NOT NULL THEN DATEADD(hour, 1, r.request_date)
        ELSE GETDATE()
    END
FROM requests r
JOIN request_statuses rs ON r.status_id = rs.request_status_id
WHERE r.request_id % 3 = 0
AND r.client_id IS NOT NULL;

-- Уведомления сотрудникам
INSERT INTO notifications (employee_id, notification_type, subject, content, sent_at)
SELECT 
    r.assigned_to,
    'email',
    'Новая заявка #' + CAST(r.request_id AS NVARCHAR),
    'Вам назначена заявка на выдачу ' + CAST(r.amount AS NVARCHAR) + ' ' + r.currency,
    CASE 
        WHEN r.assigned_date IS NOT NULL THEN r.assigned_date
        ELSE GETDATE()
    END
FROM requests r
WHERE r.assigned_to IS NOT NULL
AND r.request_id % 2 = 0;
GO

-- 10. ИНКАССАЦИИ
DECLARE @incass_cursor CURSOR;
DECLARE @incass_count INT;
DECLARE @n INT;
DECLARE @resp_emp_id INT;
DECLARE @dept_id INT;

SET @incass_cursor = CURSOR FOR SELECT department_id FROM departments;
OPEN @incass_cursor;
FETCH NEXT FROM @incass_cursor INTO @dept_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @incass_count = 2 + CAST(RAND(CHECKSUM(NEWID())) * 3 AS INT);
    SET @n = 1;
    
    WHILE @n <= @incass_count
    BEGIN
        SELECT TOP 1 @resp_emp_id = employee_id FROM employees 
        WHERE department_id = @dept_id ORDER BY NEWID();
        
        INSERT INTO cash_collections (
            department_id, responsible_employee_id, collection_date, 
            total_amount, currency, status, notes
        )
        VALUES (
            @dept_id,
            @resp_emp_id,
            DATEADD(day, -CAST(RAND(CHECKSUM(NEWID())) * 30 AS INT), GETDATE()),
            100000 + CAST(RAND(CHECKSUM(NEWID())) * 5000000 AS DECIMAL(15,2)),
            'RUB',
            CASE WHEN RAND(CHECKSUM(NEWID())) < 0.8 THEN 'выполнена' ELSE 'запланирована' END,
            'Плановая инкассация'
        );
        
        SET @n = @n + 1;
    END;
    
    FETCH NEXT FROM @incass_cursor INTO @dept_id;
END;

CLOSE @incass_cursor;
DEALLOCATE @incass_cursor;
GO