USE BankCashOrders;
GO


-- 1. —Œ«ƒ¿Õ»≈ “¿¡À»÷
CREATE TABLE departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    address NVARCHAR(MAX) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100)
);
GO

CREATE TABLE clients (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100),
    passport_number NVARCHAR(50) UNIQUE NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100)
);
GO

CREATE TABLE request_statuses (
    request_status_id INT IDENTITY(1,1) PRIMARY KEY,
    status_name NVARCHAR(50) UNIQUE NOT NULL,
    description NVARCHAR(MAX)
);
GO

CREATE TABLE employees (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    department_id INT NULL,
    last_name NVARCHAR(100) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    middle_name NVARCHAR(100),
    position NVARCHAR(100) NOT NULL,
    is_head BIT DEFAULT 0,
    phone NVARCHAR(20),
    email NVARCHAR(100),
    CONSTRAINT FK_employees_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL
);
GO

CREATE TABLE accounts (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    account_number NVARCHAR(50) UNIQUE NOT NULL,
    currency NVARCHAR(10) NOT NULL,
    opened_date DATE NOT NULL DEFAULT GETDATE(),
    status NVARCHAR(20) DEFAULT '‡ÍÚË‚ÂÌ',
    CONSTRAINT FK_accounts_client FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) ON DELETE CASCADE 
);
GO

CREATE TABLE requests (
    request_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    department_id INT NULL,
    account_id INT NOT NULL,
    created_by INT NOT NULL,
    assigned_to INT NULL,
    status_id INT NOT NULL,
    request_date DATETIME NOT NULL DEFAULT GETDATE(),
    assigned_date DATETIME NULL,
    completion_date DATETIME NULL,
    amount DECIMAL(15, 2) NOT NULL,
    currency NVARCHAR(10) NOT NULL,
    commission DECIMAL(15, 2) DEFAULT 0.00,
    expiration_date DATE NULL,
    comments NVARCHAR(MAX),
    
    CONSTRAINT FK_requests_client FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) ON DELETE NO ACTION,
    CONSTRAINT FK_requests_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT FK_requests_account FOREIGN KEY (account_id) 
        REFERENCES accounts(account_id) ON DELETE NO ACTION, 
    CONSTRAINT FK_requests_created_by FOREIGN KEY (created_by) 
        REFERENCES employees(employee_id) ON DELETE NO ACTION,
    CONSTRAINT FK_requests_assigned_to FOREIGN KEY (assigned_to) 
        REFERENCES employees(employee_id) ON DELETE SET NULL,
    CONSTRAINT FK_requests_status FOREIGN KEY (status_id) 
        REFERENCES request_statuses(request_status_id) ON DELETE NO ACTION
);
GO

CREATE TABLE transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_id INT NOT NULL,
    request_id INT NULL,
    transaction_type NVARCHAR(20) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    currency NVARCHAR(10) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT GETDATE(),
    description NVARCHAR(MAX),
    
    CONSTRAINT FK_transactions_account FOREIGN KEY (account_id) 
        REFERENCES accounts(account_id) ON DELETE NO ACTION,
    CONSTRAINT FK_transactions_request FOREIGN KEY (request_id) 
        REFERENCES requests(request_id) ON DELETE SET NULL
);
GO

CREATE TABLE request_status_history (
    request_status_history_id INT IDENTITY(1,1) PRIMARY KEY,
    request_id INT NOT NULL,
    status_id INT NOT NULL,
    changed_by INT NULL,
    changed_at DATETIME NOT NULL DEFAULT GETDATE(),
    reason NVARCHAR(MAX),
    additional_data NVARCHAR(MAX),
    
    CONSTRAINT FK_history_request FOREIGN KEY (request_id) 
        REFERENCES requests(request_id) ON DELETE CASCADE,
    CONSTRAINT FK_history_status FOREIGN KEY (status_id) 
        REFERENCES request_statuses(request_status_id) ON DELETE NO ACTION,
    CONSTRAINT FK_history_changed_by FOREIGN KEY (changed_by) 
        REFERENCES employees(employee_id) ON DELETE SET NULL
);
GO

CREATE TABLE notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NULL,
    employee_id INT NULL,
    notification_type NVARCHAR(50) NOT NULL,
    subject NVARCHAR(255),
    content NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) DEFAULT 'ÓÚÔ‡‚ÎÂÌÓ',
    sent_at DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_notifications_client FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT FK_notifications_employee FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT check_notification_recipient CHECK (
        (client_id IS NOT NULL AND employee_id IS NULL) OR
        (client_id IS NULL AND employee_id IS NOT NULL)
    )
);
GO

CREATE TABLE cash_collections (
    cash_collection_id INT IDENTITY(1,1) PRIMARY KEY,
    department_id INT NOT NULL,
    responsible_employee_id INT NULL,
    collection_date DATE NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    currency NVARCHAR(10) NOT NULL,
    status NVARCHAR(20) DEFAULT 'Á‡ÔÎ‡ÌËÓ‚‡Ì‡',
    notes NVARCHAR(MAX),
    
    CONSTRAINT FK_cash_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE CASCADE,
    CONSTRAINT FK_cash_responsible FOREIGN KEY (responsible_employee_id) 
        REFERENCES employees(employee_id) ON DELETE SET NULL
);
GO

-- 2. »Õƒ≈ —€
CREATE INDEX idx_requests_client_id ON requests(client_id);
CREATE INDEX idx_requests_department_id ON requests(department_id);
CREATE INDEX idx_requests_status_id ON requests(status_id);
CREATE INDEX idx_requests_assigned_to ON requests(assigned_to);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_request_id ON transactions(request_id);
CREATE INDEX idx_notifications_client_id ON notifications(client_id);
CREATE INDEX idx_notifications_employee_id ON notifications(employee_id);
GO

-- 3. ”Õ» ¿À‹Õ€… »Õƒ≈ — ƒÀﬂ –” Œ¬Œƒ»“≈Àﬂ
CREATE UNIQUE NONCLUSTERED INDEX unique_department_head 
ON employees(department_id, is_head) 
WHERE is_head = 1 AND department_id IS NOT NULL;
GO

-- 4. œ–Œ¬≈– ¿
SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
