USE master
GO
IF EXISTS (SELECT name
			FROM sys.databases
			WHERE name='QLbanhang4')
			DROP DATABASE QLbanhang4
GO
CREATE DATABASE QLbanhang4
GO 
USE QLbanhang4
GO
CREATE TABLE VatTu
(
	MaVT char(4) PRIMARY KEY,
	TenVT nvarchar(40) not null,
	DVTinh nvarchar(40) not null,
	SLCon int
)
GO
CREATE TABLE HoaDon
(
	MaHD char(4) PRIMARY KEY,
	NgayLap datetime not null,
	HoTenKhach nvarchar(40) not null
)
GO
CREATE TABLE CTHoaDon
(
	MaHD char(4) not null,
	MaVT char(4) not null,
	DonGiaBan money not null,
	SLBan int not null
	CONSTRAINT pk_cthoadon PRIMARY KEY(MaVT,MaHD),
	CONSTRAINT fk_cthoadon_mavt FOREIGN KEY(MaVT) REFERENCES VatTu(MaVT),
	CONSTRAINT fk_cthoadon_mahd FOREIGN KEY(MaHD) REFERENCES HoaDon(MaHD)
)
GO
INSERT INTO VatTu
VALUES('vt01',N'Máy tính',N'chiếc',20),
		('vt02',N'Súng lục',N'chiếc',30),
		('vt03',N'Điện thoại',N'chiếc',40)
GO
INSERT INTO HoaDon
VALUES('hd01','2018-02-03',N'Lưu Công Quang Vũ'),
		('hd02','2018-05-03',N'Lưu Công Quang Vũ'),
		('hd03','2018-04-03',N'Lưu Công Quang Vũ')
GO
INSERT INTO CTHoaDon
VALUES('hd01','vt01',2000,10),
		('hd01','vt02',3000,5),
		('hd02','vt02',1000,30),
		('hd02','vt03',2000,20),
		('hd03','vt03',10000,10)
GO
SELECT * FROM VatTu
SELECT * FROM HoaDon
SELECT * FROM CTHoaDon
--Cau 2
GO
CREATE FUNCTION fn_Tong(@tenvt nvarchar(40))
RETURNS money
AS
BEGIN
	DECLARE @tong money
	SELECT @tong=DonGiaBan*SLBan FROM CTHoaDon c INNER JOIN VatTu v 
									ON c.MaVT=v.MaVT
									WHERE TenVT=@tenvt
	RETURN @tong
END
GO
SELECT dbo.fn_Tong(N'Máy tính') AS TongBanHang
--Cau 3
GO
CREATE PROCEDURE sp_tong(@mavt char(4),@ngayban datetime)
AS
BEGIN
	DECLARE @tong int,@tenvt nvarchar(40)
	SELECT @tong=SUM(SLBan),@tenvt=TenVT FROM CTHoaDon c INNER JOIN HoaDon h
											ON c.MaHD=h.MaHD
											INNER JOIN VatTu v 
											ON c.MaVT=v.MaVT
											WHERE c.MaVT=@mavt AND NgayLap=@ngayban
											GROUP BY c.MaVT,TenVT
	IF(@tong>0)
		PRINT N'Tổng số lượng vật tư '+@tenvt+' bán trong ngày '+CONVERT(nvarchar(40),@ngayban)+N' là:'+CONVERT(nvarchar(40),@tong)
	ELSE
		PRINT N'Tổng số lượng vật tư '+@tenvt+' bán trong ngày '+CONVERT(nvarchar(40),@ngayban)+N' là:0'
END
GO
EXEC sp_tong 'vt01','2018-02-03'
GO
ALTER TRIGGER trg_del ON CTHoaDon
FOR DELETE
AS
BEGIN
	DECLARE @dem int
	SELECT @dem=COUNT(MaHD) FROM CTHoaDon
	IF(@dem<1)
	BEGIN
		PRINT N'Đây là dòng hoa đơn duy nhất'
		ROLLBACK TRAN
		RETURN
	END
	ELSE
	BEGIN
		UPDATE VatTu
		SET SLCon=SLCon+deleted.SLBan
		FROM VatTu
		INNER JOIN deleted
		ON deleted.MaVT=VatTu.MaVT
		WHERE deleted.MaVT=VatTu.MaVT
	END
END
GO
CREATE TRIGGER trg_insert ON CTHoaDon
FOR INSERT
AS
BEGIN 
	UPDATE VatTu
	SET SLCon=SLCon-inserted.SLBan
	FROM VatTu
	INNER JOIN inserted
	ON VatTu.MaVT=inserted.MaVT
END
GO
SELECT * FROM VatTu
SELECT * FROM CTHoaDon
GO
DELETE FROM CTHoaDon WHERE MaVT='vt02' AND MaHD='hd01'
INSERT INTO CTHoaDon VALUES('hd02','vt03',2000,10)
GO
SELECT * FROM VatTu
SELECT * FROM CTHoaDon