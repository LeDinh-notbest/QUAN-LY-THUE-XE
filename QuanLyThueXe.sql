IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyThueXe')
BEGIN
    CREATE DATABASE QuanLyThueXe;
END
GO

USE QuanLyThueXe;
GO


IF OBJECT_ID('KhachHang', 'U') IS NULL
BEGIN
    CREATE TABLE KhachHang (
        MaKH VARCHAR(10) PRIMARY KEY,
        TenKH NVARCHAR(100) NOT NULL,
        DiaChi NVARCHAR(200),
        SDT VARCHAR(15)
    );
END
GO


IF OBJECT_ID('Xe', 'U') IS NULL
BEGIN
    CREATE TABLE Xe (
        MaXe VARCHAR(10) PRIMARY KEY,
        LoaiXe NVARCHAR(50) NOT NULL,
        BienSo VARCHAR(20) UNIQUE NOT NULL,
        TrangThai NVARCHAR(20) DEFAULT 'Trong kho',
        GiaThue DECIMAL(12,2) NOT NULL
    );
END
GO


IF OBJECT_ID('DatXe', 'U') IS NULL
BEGIN
    CREATE TABLE DatXe (
        MaDatXe VARCHAR(10) PRIMARY KEY,
        MaKH VARCHAR(10) NOT NULL,
        MaXe VARCHAR(10) NOT NULL,
        NgayThue DATE NOT NULL,
        ThoiGianThue INT NOT NULL,
        CONSTRAINT FK_DatXe_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
        CONSTRAINT FK_DatXe_Xe FOREIGN KEY (MaXe) REFERENCES Xe(MaXe)
    );
END
GO


IF OBJECT_ID('ThoiGianThue', 'U') IS NULL
BEGIN
    CREATE TABLE ThoiGianThue (
        MaTG VARCHAR(10) PRIMARY KEY,
        MaDatXe VARCHAR(10) NOT NULL,
        NgayBatDau DATE NOT NULL,
        NgayKetThuc DATE NOT NULL,
        CONSTRAINT FK_ThoiGianThue_DatXe FOREIGN KEY (MaDatXe) REFERENCES DatXe(MaDatXe)
    );
END
GO


IF OBJECT_ID('HoaDon', 'U') IS NULL
BEGIN
    CREATE TABLE HoaDon (
        MaHD VARCHAR(10) PRIMARY KEY,
        MaKH VARCHAR(10) NOT NULL,
        MaXe VARCHAR(10) NOT NULL,
        TongTien DECIMAL(12,2) NOT NULL,
        NgayThanhToan DATE NOT NULL,
        CONSTRAINT FK_HoaDon_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
        CONSTRAINT FK_HoaDon_Xe FOREIGN KEY (MaXe) REFERENCES Xe(MaXe)
    );
END
GO


DELETE FROM HoaDon;
DELETE FROM ThoiGianThue;
DELETE FROM DatXe;
DELETE FROM Xe;
DELETE FROM KhachHang;
GO


INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SDT) VALUES
('KH001', N'Nguyen Van A', N'123 Đường Lê Lợi, Hà Nội', '0912345678'),
('KH002', N'Tran Thi B', N'456 Đường Hai Bà Trưng, Hà Nội', '0987654321'),
('KH003', N'Le Van C', N'789 Đường Trần Phú, Hà Nội', '0933222111');
GO

INSERT INTO Xe (MaXe, LoaiXe, BienSo, TrangThai, GiaThue) VALUES
('XE001', N'Xe ô tô 4 chỗ', '30A-12345', 'Trong kho', 500000),
('XE002', N'Xe ô tô 7 chỗ', '30B-67890', 'Trong kho', 700000),
('XE003', N'Xe máy', '29X1-23456', 'Trong kho', 150000);
GO

INSERT INTO DatXe (MaDatXe, MaKH, MaXe, NgayThue, ThoiGianThue) VALUES
('DX001', 'KH001', 'XE001', '2025-11-20', 3),
('DX002', 'KH002', 'XE003', '2025-11-18', 1),
('DX003', 'KH003', 'XE002', '2025-11-19', 2);
GO
INSERT INTO ThoiGianThue (MaTG, MaDatXe, NgayBatDau, NgayKetThuc) VALUES
('TG001', 'DX001', '2025-11-20', '2025-11-23'),
('TG002', 'DX002', '2025-11-18', '2025-11-19'),
('TG003', 'DX003', '2025-11-19', '2025-11-21');
GO

INSERT INTO HoaDon (MaHD, MaKH, MaXe, TongTien, NgayThanhToan) VALUES
('HD001', 'KH001', 'XE001', 1500000, '2025-11-23'),
('HD002', 'KH002', 'XE003', 150000, '2025-11-19'),
('HD003', 'KH003', 'XE002', 1400000, '2025-11-21');
GO



-- a) Danh sách khách hàng và xe họ đã đặt
SELECT 
    kh.MaKH,
    kh.TenKH,
    kh.SDT,
    dx.MaDatXe,
    x.LoaiXe,
    x.BienSo,
    dx.NgayThue,
    dx.ThoiGianThue
FROM KhachHang kh
JOIN DatXe dx ON kh.MaKH = dx.MaKH
JOIN Xe x ON dx.MaXe = x.MaXe;
GO

-- b) Danh sách hóa đơn, khách hàng và xe
SELECT 
    hd.MaHD,
    kh.TenKH,
    x.LoaiXe,
    x.BienSo,
    hd.TongTien,
    hd.NgayThanhToan
FROM HoaDon hd
JOIN KhachHang kh ON hd.MaKH = kh.MaKH
JOIN Xe x ON hd.MaXe = x.MaXe;
GO

-- c) Trạng thái xe và thông tin đặt xe
SELECT 
    x.MaXe,
    x.LoaiXe,
    x.BienSo,
    x.TrangThai,
    dx.MaDatXe,
    kh.TenKH,
    tg.NgayBatDau,
    tg.NgayKetThuc
FROM Xe x
LEFT JOIN DatXe dx ON x.MaXe = dx.MaXe
LEFT JOIN KhachHang kh ON dx.MaKH = kh.MaKH
LEFT JOIN ThoiGianThue tg ON dx.MaDatXe = tg.MaDatXe;
GO

-- d) Báo cáo tổng tiền từng khách hàng
SELECT 
    kh.MaKH,
    kh.TenKH,
    SUM(hd.TongTien) AS TongTienThanhToan
FROM KhachHang kh
JOIN HoaDon hd ON kh.MaKH = hd.MaKH
GROUP BY kh.MaKH, kh.TenKH;
GO