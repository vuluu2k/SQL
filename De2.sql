USE master
GO
IF EXISTS (SELECT name
			FROM sys.databases
			WHERE name='QLbanhang2')
			DROP database QLbanhang2
GO
CREATE DATABASE QLbanhang2
GO
USE QLbanhang2
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
)
--Tạo bảng Cung ứng
GO
CREATE TABLE CungUng
( 
	MaCongTy char(4) not null,
	MaSanPham char(4) not null,
	SoLuongCungUng int not null,
	GiaCungUng money not null,
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
VALUES ('sp01',N'Máy tính',20),
		('sp02',N'Điện thoại',30),
		('sp03',N'Máy tính Xách Tay',40)
--Thêm dữ liệu vào bảng Cung ứng
GO 
INSERT INTO CungUng
VALUES('ct01','sp01',30,200),
		('ct02','sp02',30,100),
		('ct02','sp03',30,500),
		('ct02','sp01',30,400),
		('ct03','sp03',30,200)
--Hiển thị bảng dữ liệu
GO
SELECT * FROM CongTy
GO
SELECT * FROM SanPham
GO
SELECT * FROM CungUng
--Hàm đưa ra tổng tiền tương ứng--Câu 2
GO
CREATE FUNCTION fn_TongTien(@tenct nvarchar(40),@tensp nvarchar(40))
RETURNS money
AS
	BEGIN
		DECLARE @tong money
		SELECT @tong=SoLuongCungUng*GiaCungUng FROM CungUng u
												INNER JOIN CongTy c ON u.MaCongTy=c.MaCongTy
												INNER JOIN SanPham s ON s.MaSanPham=u.MaSanPham
												WHERE TenCongTy=@tenct AND TenSanPham=@tensp
		RETURN @tong
	END
--Thực thi
GO
SELECT dbo.fn_TongTien(N'Công ty Xuất khẩu',N'Máy tính') AS TongTienCungUng
--Câu 3
GO
CREATE PROCEDURE sp_SanPham(@tenct nvarchar(40),@giacux money, @giacuy money)
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM CongTy WHERE TenCongTy=@tenct)
	BEGIN
		DECLARE @loi nvarchar(100)
		set @loi=N'Tên công ty '+@tenct+N' không tồn tại'
		RAISERROR(@loi,16,1)
		RETURN 1
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		SELECT TenSanPham,SoLuongCungUng,GiaCungUng FROM SanPham s 
													INNER JOIN CungUng c 
													ON s.MaSanPham=c.MaSanPham
													INNER JOIN CongTy o
													ON o.MaCongTy=c.MaCongTy
													WHERE TenCongTy=@tenct AND GiaCungUng BETWEEN @giacux AND @giacuy
		RETURN 0
	END
END
--Thực thi
GO
EXECUTE sp_SanPham N'Công ty Xuất khẩu',199,500
--EXECUTE sp_SanPham N'Công ty Xuất khẩu 10',200
--Câu 4
GO
CREATE TRIGGER trg_cungung ON CungUng
FOR insert,delete
AS
	BEGIN
		DECLARE @slcu int ,@slc int
		SELECT @slc=SoLuongCo FROM SanPham INNER JOIN inserted
											ON SanPham.MaSanPham=inserted.MaSanPham
		SELECT @slcu=inserted.SoLuongCungUng FROM inserted
		UPDATE SanPham
		SET SoLuongCo=SoLuongCo+deleted.SoLuongCungUng
		FROM SanPham INNER JOIN deleted
		ON SanPham.MaSanPham=deleted.MaSanPham
		WHERE SanPham.MaSanPham=deleted.MaSanPham
		IF(@slcu<=@slc)
		BEGIN
			UPDATE SanPham
			SET SoLuongCo=SoLuongCo-@slcu
			FROM SanPham INNER JOIN inserted
			ON SanPham.MaSanPham=inserted.MaSanPham
		END
	END
--thực thi
GO
SELECT * FROM SanPham
SELECT * FROM CungUng
GO
DELETE FROM CungUng WHERE MaSanPham='sp01' AND MaCongTy='ct01'
GO
SELECT * FROM SanPham
SELECT * FROM CungUng
GO
INSERT INTO CungUng
VALUES('ct01','sp03',40,2000)
GO
SELECT * FROM SanPham
SELECT * FROM CungUng