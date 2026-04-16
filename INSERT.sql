INSERT INTO Departments (DepartmentName, Location)
VALUES (N'IT', N'HCM'), (N'HR', N'HCM'), (N'Finance', N'HCM');

INSERT INTO Positions (Title)
VALUES (N'Intern'), (N'Junior'), (N'Senior');

WITH Numbers AS (
    SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
INSERT INTO Employees (
    EmployeeCode, FirstName, LastName, City, Status, DepartmentID, PositionID
)
SELECT 
    CONCAT('EMP', FORMAT(n,'000')),
    CHAR(65 + (n % 26)),

    CASE 
        WHEN n%3=0 THEN N'Nguyễn Văn'
        WHEN n%3=1 THEN N'Lê Thị'
        ELSE N'Phạm Văn'
    END,

    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN N'HCM'
        WHEN 1 THEN N'Hà Nội'
        WHEN 2 THEN N'Đà Nẵng'
        WHEN 3 THEN N'Cần Thơ'
        ELSE N'Hải Phòng'
    END,

    CASE 
        WHEN n%10=0 THEN N'Đã nghỉ việc'
        WHEN n%7=0 THEN N'Nghỉ thai sản'
        ELSE N'Đang làm việc'
    END,

    (n%3)+1,
    (n%3)+1
FROM Numbers;

INSERT INTO Contracts (EmployeeID, BaseSalary, Status, EndDate)
SELECT 
    EmployeeID,
    7000000 + (EmployeeID%3)*3000000,

    CASE 
        WHEN Status = N'Đã nghỉ việc' THEN 'Terminated'
        ELSE 'Active'
    END,

    CASE 
        WHEN Status = N'Đã nghỉ việc' THEN GETDATE()
        ELSE NULL
    END
FROM Employees;

INSERT INTO Attendance (
    EmployeeID, WorkDate, CheckInTime, CheckOutTime, WorkHours, Status
)
SELECT 
    e.EmployeeID,
    w.WorkDate,

    CASE 
        WHEN e.Status = N'Nghỉ thai sản' THEN NULL
        ELSE DATEADD(HOUR,8,CAST(w.WorkDate AS DATETIME))
    END,

    CASE 
        WHEN e.Status = N'Nghỉ thai sản' THEN NULL
        ELSE DATEADD(HOUR,17,CAST(w.WorkDate AS DATETIME))
    END,

    CASE 
        WHEN e.Status = N'Nghỉ thai sản' THEN 0
        ELSE 8
    END,

    CASE 
        WHEN e.Status = N'Nghỉ thai sản' THEN 'Absent'
        ELSE 'Present'
    END

FROM Employees e
CROSS JOIN (
    SELECT TOP 5 
        CAST(DATEADD(DAY,-ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),GETDATE()) AS DATE) AS WorkDate
    FROM sys.objects
) w
WHERE e.Status <> N'Đã nghỉ việc';

INSERT INTO Payroll (EmployeeID, PayPeriod, BaseSalary, Allowances, Deductions)
SELECT 
    e.EmployeeID,
    '2024-04',
    CASE 
        WHEN e.Status = N'Nghỉ thai sản' THEN 3000000
        ELSE c.BaseSalary
    END,
    500000,
    200000
FROM Employees e
JOIN Contracts c ON e.EmployeeID = c.EmployeeID
WHERE e.Status <> N'Đã nghỉ việc';

-- =========================== --
UPDATE Employees
SET PositionID = (ABS(CHECKSUM(NEWID())) % 3) + 1;

UPDATE Contracts
SET BaseSalary = 
    CASE 
        WHEN EmployeeID % 3 = 0 THEN 30000000
        WHEN EmployeeID % 2 = 0 THEN 15000000
        ELSE 7000000
    END;

UPDATE Contracts
SET Status = 'Expired',
    EndDate = GETDATE()
WHERE EmployeeID IN (
    SELECT EmployeeID 
    FROM Employees 
    WHERE Status = N'Đã nghỉ việc'
);

UPDATE Attendance
SET Status = 
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 0 THEN 'Late'
        ELSE 'Present'
    END;

UPDATE Attendance
SET Status = 'Late'
WHERE EmployeeID IN (1,2,3)
AND DAY(WorkDate) <= 5;

DELETE FROM Contracts
WHERE EmployeeID IN (
    SELECT TOP 5 EmployeeID
    FROM Employees
    WHERE Status = N'Đang làm việc'
);

UPDATE Payroll
SET NetSalary = 
    CASE 
        WHEN EmployeeID % 3 = 0 THEN 40000000
        WHEN EmployeeID % 2 = 0 THEN 20000000
        ELSE 10000000
    END;
