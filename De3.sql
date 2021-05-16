USE master
GO
IF EXISTS (SELECT name
			FROM sys.databases
			WHERE name='QLSinhVien3')
			DROP database QLSinhVien3
GO
CREATE DATABASE QLSinhVien3
GO
USE QLSinhVien3
--Tạo bảng  Công ty
GO 
CREATE TABLE Khoa
(
	MaKhoa char(4) PRIMARY KEY,
	TenKhoa nvarchar(40) not null,
	NgayThanhLap datetime not null,
)
--Tạo bảng Sản phẩm
GO
CREATE TABLE Lop
(
	MaLop char(4) PRIMARY KEY,
	TenLop nvarchar(40) not null,
	MaKhoa char(4) not null,
	CONSTRAINT fk_lop_makhoa FOREIGN KEY(MaKhoa) REFERENCES Khoa(MaKhoa)
)
--Tạo bảng Cung ứng
GO
CREATE TABLE SinhVien
( 
	MaSV char(4) PRIMARY KEY,
	HoTen nvarchar(40) not null,
	NgaySinh datetime not null,
	MaLop char(4) not null,
	CONSTRAINT fk_sinhvien_malop FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)
--Thêm dữ liệu vào bảng Công ty
GO
INSERT INTO Khoa
VALUES('k01',N'Công nghệ thông tin','2018-04-22'),
		('k02',N'Hệ thống thông tin','2019-04-22'),
		('k03',N'Khoa học máy tính','2020-04-22')
--Thêm dữ liệu vào bảng Sản phẩm
GO
INSERT INTO Lop
VALUES ('l01',N'CNNT01','k01'),
		('l02',N'HTTT01','k01'),
		('l03',N'KHMT01','k02'),
--Thêm dữ liệu vào bảng Cung ứng
GO 
INSERT INTO SinhVien
VALUES('sv01',N'Lưu Công Quang Vũ','2000-04-03','l01'),
		('sv02',N'Lưu Công Quang Vũ','2000-04-03','l01'),
		('sv03',N'Lưu Công Quang Vũ','2000-04-03','l02'),
		('sv04',N'Lưu Công Quang Vũ','2000-04-03','l03'),
		('sv05',N'Lưu Công Quang Vũ','2000-04-03','l02'),
		('sv06',N'Lưu Công Quang Vũ','2000-04-03','l02')

--Hiển thị bảng dữ liệu
GO
SELECT * FROM Khoa
GO
SELECT * FROM Lop
GO
SELECT * FROM SinhVien
--Cau 2
GO
CREATE VIEW vLop
AS
	SELECT s.MaLop,TenLop,TenKhoa,COUNT(MaSV) AS SiSo FROM SinhVien s 
										INNER JOIN Lop l
										ON s.MaLop=l.MaLop
										INNER JOIN Khoa k
										ON k.MaKhoa=l.MaKhoa
		GROUP BY s.MaLop,TenLop,TenKhoa
--Thực thi
GO
SELECT * FROM vLop
--Cau 3
GO
CREATE PROCEDURE sp_list(@tenkhoa nvarchar(40),@x int)
AS 
BEGIN
	IF NOT EXISTS(SELECT COUNT(MaSV)FROM SinhVien s 
						INNER JOIN Lop l
						ON s.MaLop=l.MaLop
						INNER JOIN Khoa k
						ON k.MaKhoa=l.MaKhoa WHERE TenKhoa=@tenkhoa
						GROUP BY s.MaLop
						HAVING COUNT(MaSV)>@x)
	BEGIN
		PRINT N'Không có lớp nào có sĩ số lơn hơn đã nhâp'
		ROLLBACK TRAN
		RETURN
	END	
	ELSE
	BEGIN
		SELECT Lop.MaLop,TenLop,SiSo=COUNT(MaSV) FROM Lop INNER JOIN SinhVien ON Lop.MaLop=SinhVien.MaLop INNER JOIN Khoa ON Khoa.MaKhoa=Lop.MaKhoa WHERE TenKhoa=@tenkhoa GROUP BY Lop.MaLop,TenLop HAVING COUNT(MaSV)>@x
	END
END
--Thực thi
GO
SELECT COUNT(MaSV) FROM SinhVien s 
						INNER JOIN Lop l
						ON s.MaLop=l.MaLop
						INNER JOIN Khoa k
						ON k.MaKhoa=l.MaKhoa
						GROUP BY s.MaLop
						HAVING COUNT(MaSV)>1
EXEC sp_list N'Công nghệ thông tin', 1
--Cau 4
GO
ALTER TRIGGER Del_Lop ON LOP
FOR DELETE
AS
	BEGIN
		DECLARE @SiSo int, @tenlop nvarchar(40)
		SELECT @tenlop=deleted.TenLop FROM deleted
		SELECT @SiSo=COUNT(MaSV) FROM SinhVien s INNER JOIN deleted ON s.MaLop=deleted.MaLop
		IF(@SiSo>0)
		BEGIN
			PRINT N'Tên Lớp '+@tenlop+N' có sinh viên với sĩ số là: '+CONVERT(nvarchar(40),@SiSo) 
			ROLLBACK TRAN
			RETURN
		END
	END
GO
SELECT * FROM Lop
GO
ALTER TABLE SinhVien NOCHECK CONSTRAINT ALL
GO
DELETE FROM Lop WHERE MaLop='l04'
GO
ALTER TABLE SinhVien CHECK CONSTRAINT ALL