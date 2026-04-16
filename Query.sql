--Câu 1: Liệt kê tất cả nhân viên đang làm việc (Status = 'Đang làm việc') và sắp xếp theo tên tăng dần.
SELECT	e.DepartmentID,
		e.EmployeeCode,
		e.LastName+' ' +e.FirstName AS FullName ,
		e.Status,
		e.City
FROM Employees e
WHERE e.Status = N'Đang làm việc'
ORDER BY e.FirstName ASC, e.LastName ASC;

--Câu 2: Hiển thị danh sách các phòng ban và địa chỉ của từng phòng.
SELECT d.DepartmentName,d.Location FROM Departments d

--Câu 3: Tìm những nhân viên còn làm việc ở thành phố 'HCM' thuộc phòng 'IT'.
SELECT*
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.City = 'HCM' AND d.DepartmentName = 'IT' AND e.IsActive = 1

--Câu 4: Lấy ra danh sách các chức danh công việc hiện có trong công ty.
SELECT DISTINCT 
    p.Title
FROM Positions p
JOIN Employees e ON p.PositionID = e.PositionID
WHERE e.Status = N'Đang làm việc';

--Câu 5: Đếm số lượng nhân viên đang nghỉ thai sản.
SELECT COUNT(e.EmployeeID) 
FROM Employees e
WHERE e.Status = N'Nghỉ thai sản'

--Câu 6: Hiển thị thông tin nhân viên gồm: mã nhân viên, tên, phòng ban và chức danh.
SELECT	e.EmployeeID,e.EmployeeCode,
		e.LastName +' '+ e.FirstName AS FullName,
		d.DepartmentName,
		p.Title
FROM Employees e
LEFT JOIN Positions p ON e.PositionID = p.PositionID
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, FullName;
--Câu 7: Liệt kê danh sách nhân viên kèm theo mức lương cơ bản từ bảng Contracts.
SELECT	e.EmployeeID,
		e.EmployeeCode,
		e.LastName +' '+ e.FirstName AS FullName,
		c.BaseSalary
FROM Employees e
LEFT JOIN Contracts c ON c.EmployeeID = e.EmployeeID
--Câu 8: Tìm thông tin chấm công của nhân viên có mã 'EMP001' trong tháng 04/2026.
SELECT * 
FROM Employees e JOIN Attendance a ON e.EmployeeID = a.EmployeeID
WHERE e.EmployeeCode = 'EMP001' AND MONTH (WorkDate) = 4 AND YEAR(WorkDate) = 2026

--Câu 9: Lấy danh sách các nhân viên đã nghỉ việc kèm theo ngày kết thúc hợp đồng.
SELECT	e.EmployeeID,
		e.EmployeeCode, 
		e.LastName+' ' +e.FirstName AS FullName ,
		c.EndDate
FROM Employees e JOIN Contracts c ON e.EmployeeID = c.EmployeeID
WHERE e.Status = N'Đã nghỉ việc' AND e.IsActive = 0

--Câu 10: Hiển thị những nhân viên có mức lương cơ bản lớn hơn 10,000,000.
SELECT *
FROM Employees e JOIN Contracts c ON e.EmployeeID = c.EmployeeID
WHERE c.BaseSalary > 10000000

--Câu 11: Tính tổng số lượng nhân viên của mỗi phòng ban.
SELECT d.DepartmentName, COUNT(e.EmployeeID) AS EmployeeTotal
FROM Employees e JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName

--Câu 12: Tính mức lương trung bình của mỗi chức danh.
SELECT p.Title, AVG(c.BaseSalary)  AS SalaryTotal
FROM Employees e JOIN Contracts c ON e.EmployeeID = c.EmployeeID
JOIN Positions p ON e.PositionID = p.PositionID
GROUP BY p.Title

--Câu 13: Thống kê tổng số giờ làm việc của từng nhân viên trong tháng 04/2026.
SELECT	e.EmployeeID,
		e.EmployeeCode,
		e.LastName+' ' +e.FirstName AS FullName ,
		SUM(a.WorkHours) WorkHoursTotal
FROM Employees e JOIN Attendance a ON e.EmployeeID = a.EmployeeID
WHERE a.WorkDate >= '2026-04-01' AND a.WorkDate <= '2026-04-30'
GROUP BY e.EmployeeID,e.EmployeeCode,e.LastName,e.FirstName 

--Câu 14: Tìm những phòng ban có trên 33 nhân viên.
SELECT e.DepartmentID, d.DepartmentName, COUNT(*) AS ECOUNT
FROM Employees e JOIN Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY e.DepartmentID,d.DepartmentName
HAVING COUNT(*) > 33


--Câu 15: Liệt kê top 5 nhân viên có mức lương thực nhận cao nhất trong kỳ lương.
SELECT TOP 5
    e.EmployeeCode,
    e.LastName + ' ' + e.FirstName AS FullName,
    p.NetSalary
FROM Payroll p
JOIN Employees e ON p.EmployeeID = e.EmployeeID
ORDER BY p.NetSalary DESC;

--Câu 16: Tìm những nhân viên đi làm trễ nhiều hơn 3 lần trong một tháng.
SELECT 
    e.EmployeeCode,
    e.LastName + ' ' + e.FirstName AS FullName,
    COUNT(*) AS LateCount
FROM Attendance a
JOIN Employees e ON a.EmployeeID = e.EmployeeID
WHERE a.Status = 'Late'
    AND MONTH(a.WorkDate) = 4
    AND YEAR(a.WorkDate) = 2026
GROUP BY e.EmployeeCode, e.LastName, e.FirstName
HAVING COUNT(*) > 3;

--Câu 17: Tính tổng quỹ lương thực tế công ty phải chi trả cho từng phòng ban trong tháng.
SELECT 
    d.DepartmentName AS Department,
    COUNT(p.PayrollID) AS EmpTotal,
    SUM(p.NetSalary) AS SalatyTotal
FROM Departments d
JOIN Employees e ON d.DepartmentID = e.DepartmentID
JOIN Payroll p ON e.EmployeeID = p.EmployeeID
WHERE p.PayPeriod = '2024-04'
GROUP BY d.DepartmentName
ORDER BY SalatyTotal DESC;

--Câu 18: Tìm những nhân viên đang làm việc nhưng chưa có hợp đồng.
SELECT e.EmployeeID,c.ContractID
FROM Employees e LEFT JOIN Contracts c ON e.EmployeeID = c.EmployeeID
WHERE e.Status = N'Đang làm việc' AND c.ContractID IS NULL

--Câu 19: Tạo báo cáo gồm: mã nhân viên, tên nhân viên, tổng ngày công và tổng lương trong tháng.
SELECT 
    e.EmployeeCode,
    e.LastName + ' ' + e.FirstName AS FullName,
    ISNULL(a.TotalDays, 0) AS TotalDays,
    ISNULL(p.TotalSalary, 0) AS TotalSalary
FROM Employees e

LEFT JOIN (
    SELECT EmployeeID, COUNT(*) AS TotalDays
    FROM Attendance
    WHERE MONTH(WorkDate) = 4 AND YEAR(WorkDate) = 2026
    GROUP BY EmployeeID
) a ON e.EmployeeID = a.EmployeeID

LEFT JOIN (
    SELECT EmployeeID, SUM(NetSalary) AS TotalSalary
    FROM Payroll
    GROUP BY EmployeeID
) p ON e.EmployeeID = p.EmployeeID;

--Câu 20: Tìm những nhân viên có mức lương cao hơn mức lương trung bình của phòng ban mà họ đang làm việc.
SELECT 
    e.EmployeeCode,
    e.LastName + ' ' + e.FirstName AS FullName,
    c.BaseSalary,
    e.DepartmentID
FROM Employees e
JOIN Contracts c ON e.EmployeeID = c.EmployeeID
WHERE c.BaseSalary > (
    SELECT AVG(c2.BaseSalary)
    FROM Employees e2
    JOIN Contracts c2 ON e2.EmployeeID = c2.EmployeeID
    WHERE e2.DepartmentID = e.DepartmentID
);