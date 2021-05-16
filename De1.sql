USE master
GO
IF EXISTS (SELECT name
			FROM sys.databases
			WHERE name='QLbanhang1')
			DROP database QLbanhang1
GO
CREATE DATABASE QLbanhang1
GO
USE QLbanhang1
--Tạo bảng  Công ty
GO 
CREATE TABLE CongTy
(
	MaCongTy char(4) PRIMARY KEY,
	TenCongTy nvarchar(40) not null,
	NgayThanhLap datetime not null,
)
--Tạo bảng Sản phẩm
GO
CREATE TABLE SanPham
(
	MaSanPham char(4) PRIMARY KEY,
	TenSanPham nvarchar(40) not null,
	SoLuongCo int not null,
	GiaBan money not null
)
--Tạo bảng Cung ứng
GO
CREATE TABLE CungUng
( 
	MaCongTy char(4) not null,
	MaSanPham char(4) not null,
	SoLuongCungUng int not null,
	CONSTRAINT pk_cungung PRIMARY KEY(MaCongTy,MaSanPham),
	CONSTRAINT fk_cungung_congty FOREIGN KEY(MaCongTy) REFERENCES CongTy(MaCongTy),
	CONSTRAINT fk_cungung_sanpham FOREIGN KEY(MaSanPham) REFERENCES SanPham(MaSanPham)
)
--Thêm dữ liệu vào bảng Công ty
GO
INSERT INTO CongTy
VALUES('ct01',N'Công ty Xuất khẩu','2018-04-22'),
		('ct02',N'Công ty Xuất khẩu 1','2019-04-22'),
		('ct03',N'Công ty Xuất khẩu 2','2020-04-22')
--Thêm dữ liệu vào bảng Sản phẩm
GO
INSERT INTO SanPham
VALUES ('sp01',N'Máy tính',20,100),
		('sp02',N'Điện thoại',30,150),
		('sp03',N'Máy tính Xách Tay',40,500)
--Thêm dữ liệu vào bảng Cung ứng
GO 
INSERT INTO CungUng
VALUES('ct01','sp01',30),
		('ct02','sp02',30),
		('ct02','sp03',30),
		('ct02','sp01',30),
		('ct03','sp03',30)
--Hiển thị bảng dữ liệu
GO
SELECT * FROM CongTy
GO
SELECT * FROM SanPham
GO
SELECT * FROM CungUng
--cau2
GO
CREATE FUNCTION fn_display(@tenct nvarchar(40))
RETURNS @SANPHAM TABLE(
						TenSanPham nvarchar(40),
						SoLuongCungUng int,
						GiaBan money,
						TongTien money
						)
AS 
BEGIN
	INSERT INTO @SANPHAM
						SELECT TenSanPham,SoLuongCungUng,GiaBan,TongTien=SoLuongCungUng*GiaBan
						FROM SanPham 
						INNER JOIN CungUng 
						ON SanPham.MaSanPham=CungUng.MaSanPham
						INNER JOIN CongTy
						ON CongTy.MaCongTy=CungUng.MaCongTy
						WHERE TenCongTy=@tenct
	RETURN
END
--thực thi
GO
SELECT * FROM fn_display(N'Công ty Xuất khẩu')
--Cau 3
GO
CREATE PROCEDURE sp_insert(@masp char(4),@tensp nvarchar(40),@slc int,@gb money)
AS
BEGIN
	IF(@slc<=0 OR @gb<=0) 
	BEGIN
		DECLARE @error nvarchar(100)
		SET @error=N'Sản phẩm '+@tensp+N' nhập dữ liệu sai'
		RAISERROR(@error,16,1)
		RETURN 1
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		INSERT INTO SanPham
		VALUES(@masp,@tensp,@slc,@gb)
		RETURN 0
	END
END
--Thực thi
GO
EXEC sp_insert 'sp04',N'Điện thoại thông minh',0,300
GO
SELECT * FROM SanPham
--Câu 4
GO
CREATE TRIGGER Updated ON CungUng
FOR UPDATE
AS
BEGIN
	DECLARE @old int , @new int, @slc int
	SELECT @slc=SoLuongCo FROM SanPham INNER JOIN deleted ON SanPham.MaSanPham=deleted.MaSanPham
	SELECT @old=deleted.SoLuongCungUng FROM deleted
	SELECT @new=inserted.SoLuongCungUng FROM inserted
	IF(@new-@old<=@slc)
	BEGIN
		UPDATE SanPham
		SET SoLuongCo=SoLuongCo-(@new-@old)
		FROM SanPham s
		INNER JOIN inserted
		ON s.MaSanPham=inserted.MaSanPham
		INNER JOIN deleted
		ON s.MaSanPham=deleted.MaSanPham
	END
END
GO
CREATE TRIGGER Del ON CungUng
FOR DELETE
AS
BEGIN
	UPDATE SanPham
	SET SoLuongCo=SoLuongCo+deleted.SoLuongCungUng
	FROM SanPham s
	INNER JOIN deleted
	ON s.MaSanPham=deleted.MaSanPham
	WHERE s.MaSanPham=deleted.MaSanPham
END
--Thực thi
GO
SELECT * FROM SanPham
SELECT * FROM CungUng
GO
DELETE FROM CungUng WHERE MaCongTy='ct02' AND MaSanPham='sp01'
GO
SELECT * FROM SanPham
SELECT * FROM CungUng
GO
UPDATE CungUng SET SoLuongCungUng=50 WHERE MaCongTy='ct02' AND MaSanPham='sp03'
GO
SELECT * FROM SanPham
SELECT * FROM CungUng