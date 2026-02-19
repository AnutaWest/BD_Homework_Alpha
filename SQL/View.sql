USE BankCashOrders;
GO

CREATE VIEW vw_cash_delivery_monthly AS
SELECT 
    d.name AS отделение,
    d.address AS адрес,
    COUNT(r.request_id) AS количество_выдач,
    ISNULL(SUM(r.amount), 0) AS общая_сумма,
    ISNULL(AVG(r.amount), 0) AS средняя_сумма,
    ISNULL(SUM(r.commission), 0) AS общая_комиссия
FROM departments d
LEFT JOIN requests r ON d.department_id = r.department_id
    AND r.status_id = (SELECT request_status_id FROM request_statuses WHERE status_name = 'Выдана')
    AND MONTH(r.completion_date) = MONTH(GETDATE())
    AND YEAR(r.completion_date) = YEAR(GETDATE())
GROUP BY d.department_id, d.name, d.address;
GO

SELECT * FROM vw_cash_delivery_monthly;
GO