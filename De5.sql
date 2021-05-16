USE master
GO
IF EXISTS (SELECT name
			FROM sys.databases
			WHERE name='QLSinhVien5')
			DROP database QLSinhVien5
GO
CREATE DATABASE QLSinhVien5
GO
USE QLSinhVien5
--Tạo bảng  Công ty
GO 
CREATE TABLE Khoa
(
	MaKhoa char(4) PRIMARY KEY,
	TenKhoa nvarchar(40) not null,
	SoDienThoai char(10) not null,
)
--Tạo bảng Sản phẩm
GO
CREATE TABLE Lop
(
	MaLop char(4) PRIMARY KEY,
	TenLop nvarchar(40) not null,
	SiSo int not null,
	MaKhoa char(4) not null,
	CONSTRAINT fk_lop_makhoa FOREIGN KEY(MaKhoa) REFERENCES Khoa(MaKhoa)
)
--Tạo bảng Cung ứng
GO
CREATE TABLE SinhVien
( 
	MaSV char(4) PRIMARY KEY,
	HoTen nvarchar(40) not null,
	GioiTinh nvarchar(40) not null,
	NgaySinh datetime not null,
	MaLop char(4) not null,
	CONSTRAINT fk_sinhvien_malop FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)
--Thêm dữ liệu vào bảng Công ty
GO
INSERT INTO Khoa
VALUES('k01',N'Công nghệ thông tin','0123456789'),
		('k02',N'Hệ thống thông tin','0898709170'),
		('k03',N'Khoa học máy tính','0909180700')
--Thêm dữ liệu vào bảng Sản phẩm
GO
INSERT INTO Lop
VALUES ('l01',N'CNNT01',20,'k01'),
		('l02',N'HTTT01',30,'k01'),
		('l03',N'KHMT01',40,'k02')
--Thêm dữ liệu vào bảng Cung ứng
GO 
INSERT INTO SinhVien
VALUES('sv01',N'Lưu Công Quang Vũ',N'Nam','2000-04-03','l01'),
		('sv02',N'Lưu Công Quang Vũ',N'Nữ','2000-04-03','l01'),
		('sv03',N'Lưu Công Quang Vũ',N'Nam','2000-04-03','l02'),
		('sv04',N'Lưu Công Quang Vũ',N'Nam','2000-04-03','l03'),
		('sv05',N'Lưu Công Quang Vũ',N'Nữ','2000-04-03','l02'),
		('sv06',N'Lưu Công Quang Vũ',N'Nữ','2000-04-03','l02')
--Hiển thị bảng dữ liệu
GO
SELECT * FROM Khoa
GO
SELECT * FROM Lop
GO
SELECT * FROM SinhVien
--Cau 2
GO
CREATE FUNCTION fn_table(@tenkhoa nvarchar(40))
RETURNS @LOP TABLE(
					MaLop char(4),
					TenLop nvarchar(40),
					SiSo int
					)
AS
	BEGIN
	INSERT INTO @LOP 
					SELECT MaLop,TenLop,SiSo FROM Lop INNER JOIN Khoa
											ON Lop.MaKhoa=Khoa.MaKhoa
											WHERE TenKhoa=@tenkhoa
	RETURN
	END
GO
SELECT * FROM fn_table(N'Công nghệ thông tin')
--Cau 3
GO
CREATE PROCEDURE sp_insert(@masv char(4), @hoten nvarchar(40), @ngaysinh datetime, @gioitinh nvarchar(40), @tenlop nvarchar(40))
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Lop WHERE TenLop=@tenlop)
	BEGIN
		PRINT N'Lớp không tồn tại'
		RETURN
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		DECLARE @malop char(4)
		SELECT @malop=MaLop FROM Lop WHERE TenLop=@tenlop
		INSERT INTO SinhVien
		VALUES(@masv,@hoten,@gioitinh,@ngaysinh,@malop)
	END
END
GO
EXECUTE sp_insert 'sv11',N'Hoàng Thị Bích','2000-11-15',N'Nữ','CNNT01'
GO
SELECT * FROM SinhVien
--Cau 4
GO
CREATE TRIGGER trg_update ON SinhVien
FOR UPDATE
AS
BEGIN
	DECLARE @old char(4),@new char(4), @SiSo int,@SiSo1 int,@tenlop nvarchar(40)
	SELECT @old=deleted.MaLop FROM deleted
	SELECT @new=inserted.MaLop FROM inserted
	SELECT @SiSo1=SiSo FROM Lop INNER JOIN deleted ON Lop.MaLop=deleted.MaLop WHERE Lop.MaLop=@old
	SELECT @SiSo=SiSo,@tenlop=TenLop FROM Lop INNER JOIN inserted ON Lop.MaLop=inserted.MaLop WHERE Lop.MaLop=@new
	IF(@SiSo>=80)
	BEGIN
		PRINT N'Lớp '+@tenlop+N' đã đủ'
		RETURN
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		UPDATE Lop
		SET @SiSo=@SiSo+1,@SiSo1=@SiSo1-1
		FROM Lop 
		INNER JOIN deleted
		ON Lop.MaLop=deleted.MaLop
		INNER JOIN inserted
		ON Lop.MaLop=inserted.MaLop
	END
END
GO
SELECT * FROM Lop
SELECT * FROM SinhVien
GO
UPDATE SinhVien SET MaLop='l01' WHERE MaSV='sv03'
GO
SELECT * FROM Lop
SELECT * FROM SinhVien