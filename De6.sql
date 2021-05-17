USE master
GO
IF EXISTS(SELECT name
		FROM sys.databases
		WHERE name='QLHANG')
	DROP DATABASE QLHANG
GO
CREATE DATABASE QLHANG
GO
USE QLHANG
GO
CREATE TABLE HANG
(
MaHang char(5) PRIMARY KEY,
TenHang nvarchar(50) not null,
SoLuongCo int not null)
GO
INSERT INTO HANG VALUES('SP001',N'Tên hàng 1',120)
INSERT INTO HANG VALUES('SP002',N'Tên hàng 2',200)
INSERT INTO HANG VALUES('SP003',N'Tên hàng 3',135)
GO
--
CREATE TABLE HDBan(
MaHD chaR(5) PRIMARY KEY,
NgayBan date NOT NULL,
HoTenKH nvarchar(50) NOT NULL,)
GO
-- 
INSERT INTO HDBan VALUES ('HD001', '2021/05/20',N'Nguyễn Văn A')
INSERT INTO HDBan VALUES ('HD002', '2021/03/03',N'Nguyễn Văn B')
INSERT INTO HDBan VALUES ('HD003', '2021/09/09',N'Nguyễn Văn C')
GO
--
CREATE TABLE HangBan(
MaHD char(5),
MaHang char(5),
DonGiaBan money NOT NULL,
SoLuongBan int NOT NULL,
CONSTRAINT pk_hb PRIMARY KEY(MaHD,MaHang),
CONSTRAINT fk_hd FOREIGN KEY(MaHD) REFERENCES HDBan(MaHD),
CONSTRAINT fk_h FOREIGN KEY(MaHang) REFERENCES HANG(MaHang))
GO
--
INSERT INTO HangBan VALUES('HD001','SP001',300000,12)
INSERT INTO HangBan VALUES('HD002','SP001',350000,12)
INSERT INTO HangBan VALUES('HD001','SP002',250000,12)
INSERT INTO HangBan VALUES('HD003','SP002',410000,12)
INSERT INTO HangBan VALUES('HD002','SP003',320000,12)
GO
SELECT * FROM HANG
SELECT * FROM HangBan
SELECT * FROM HDBan
GO
CREATE FUNCTION fn_hang(@x datetime,@y datetime)
RETURNS @HANG TABLE(
					MaH char(10),
					TenH nvarchar(40),
					TongSoLuong int
					)
AS
BEGIN
	INSERT INTO @HANG 
					SELECT HANG.MaHang,TenHang,SUM(SoLuongBan) FROM HANG
															INNER JOIN HangBan
															ON HANG.MaHang=HangBan.MaHang
															INNER JOIN HDBan
															ON HangBan.MaHD=HDBan.MaHD
															WHERE NgayBan BETWEEN @x AND @y
															GROUP BY HANG.MaHang,TenHang
	RETURN
END
GO
SELECT * FROM fn_hang('2021/03/03','2021/10/03')
GO
CREATE PROCEDURE sp_insert(@mahd char(10),@tenhang nvarchar(40),@dongia money,@slb int)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM HANG WHERE TenHang=@tenhang)
	BEGIN
		PRINT N'Tên hàng '+@tenhang+N' không tồn tại'
		ROLLBACK TRAN
		RETURN 
	END
	ELSE
	BEGIN
		DECLARE @mahang char(10)
		SELECT @mahang=MaHang FROM HANG WHERE TenHang=@tenhang
		INSERT INTO HangBan
		VALUES(@mahd,@mahang,@dongia,@slb)
		RETURN
	END
END
GO
EXEC sp_insert 'HD003',N'Tên hàng 1',2000,20
GO
EXEC sp_insert 'HD003',N'Tên hàng 4',2000,20
GO
SELECT * FROM HangBan
GO
CREATE TRIGGER trg_them ON HangBan
FOR INSERT,DELETE
AS
BEGIN
	
	DECLARE @slb int,@slc int
	SELECT @slc=SoLuongCo FROM HANG INNER JOIN inserted ON HANG.MaHang=inserted.MaHang
	SELECT @slb=inserted.SoLuongBan FROM inserted
	IF EXISTS (SELECT * FROM deleted)
	BEGIN
		UPDATE HANG
		SET SoLuongCo=SoLuongCo+deleted.SoLuongBan
		FROM HANG 
		INNER JOIN deleted
		ON HANG.MaHang=deleted.MaHang
		WHERE HANG.MaHang=deleted.MaHang
		
	END
	IF(@slb<=@slc)
	BEGIN
		UPDATE HANG
		SET SoLuongCo=SoLuongCo-@slb
		FROM HANG 
		INNER JOIN inserted
		ON HANG.MaHang=inserted.MaHang
	END
	ELSE IF(@slb>@slc)
	BEGIN
		PRINT N'Lỗi số lượng bán vượt quá số lượng có'
		ROLLBACK TRAN
		RETURN
	END
END

GO
SELECT * FROM HANG
SELECT * FROM HangBan
GO
DELETE FROM HangBan WHERE MaHang='SP0011' AND MaHD='HD001'
INSERT INTO HangBan VALUES('HD001','SP003',1000,100)
GO
SELECT * FROM HANG
SELECT * FROM HangBan