CREATE DATABASE HRM_DB;
GO
USE HRM_DB;
GO

CREATE TABLE Departments (
    DepartmentID INT IDENTITY PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100),
    IsActive BIT DEFAULT 1
);


CREATE TABLE Positions (
    PositionID INT IDENTITY PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    IsActive BIT DEFAULT 1
);

CREATE TABLE Employees (
    EmployeeID INT IDENTITY PRIMARY KEY,
    EmployeeCode VARCHAR(10) UNIQUE NOT NULL,

    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    City NVARCHAR(100),

    Status NVARCHAR(50) DEFAULT N'Đang làm việc'
    CHECK (Status IN (N'Đang làm việc', N'Đã nghỉ việc', N'Nghỉ thai sản')),

    -- AUTO LOGIC
    IsActive AS (
        CASE 
            WHEN Status = N'Đã nghỉ việc' THEN 0 
            ELSE 1 
        END
    ),

    DepartmentID INT NOT NULL,
    PositionID INT NOT NULL,

    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (PositionID) REFERENCES Positions(PositionID)
);

CREATE TABLE Contracts (
    ContractID INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,

    BaseSalary DECIMAL(18,2) NOT NULL,

    Status NVARCHAR(50) DEFAULT 'Active'
    CHECK (Status IN ('Active', 'Terminated')),

    StartDate DATE DEFAULT GETDATE(),
    EndDate DATE NULL,

    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Attendance (
    AttendanceID INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,

    WorkDate DATE NOT NULL,
    CheckInTime DATETIME NULL,
    CheckOutTime DATETIME NULL,

    WorkHours DECIMAL(5,2) DEFAULT 0
    CHECK (WorkHours >= 0),

    Status NVARCHAR(50) DEFAULT 'Present'
    CHECK (Status IN ('Present', 'Absent', 'Late', 'HalfDay')),

    -- mỗi ngày 1 record
    CONSTRAINT UQ_Employee_WorkDate UNIQUE (EmployeeID, WorkDate),

    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

 
CREATE TABLE Payroll (
    PayrollID INT IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,

    PayPeriod VARCHAR(7) NOT NULL, -- YYYY-MM

    BaseSalary DECIMAL(18,2),
    Allowances DECIMAL(18,2) DEFAULT 0,
    Deductions DECIMAL(18,2) DEFAULT 0,

    NetSalary AS (BaseSalary + Allowances - Deductions),

    CreatedAt DATETIME DEFAULT GETDATE(),

    CONSTRAINT UQ_Employee_PayPeriod UNIQUE (EmployeeID, PayPeriod),

    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE INDEX IX_Employees_DepartmentID ON Employees(DepartmentID);
CREATE INDEX IX_Attendance_EmployeeID ON Attendance(EmployeeID);
CREATE INDEX IX_Payroll_EmployeeID ON Payroll(EmployeeID);