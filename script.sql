USE [master]
GO
/****** Object:  Database [Librarydatabase]    Script Date: 18-12-2024 12:51:36 ******/
CREATE DATABASE [Librarydatabase]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Librarydatabase', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Librarydatabase.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Librarydatabase_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Librarydatabase_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Librarydatabase] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Librarydatabase].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Librarydatabase] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Librarydatabase] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Librarydatabase] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Librarydatabase] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Librarydatabase] SET ARITHABORT OFF 
GO
ALTER DATABASE [Librarydatabase] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Librarydatabase] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Librarydatabase] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Librarydatabase] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Librarydatabase] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Librarydatabase] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Librarydatabase] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Librarydatabase] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Librarydatabase] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Librarydatabase] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Librarydatabase] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Librarydatabase] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Librarydatabase] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Librarydatabase] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Librarydatabase] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Librarydatabase] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Librarydatabase] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Librarydatabase] SET RECOVERY FULL 
GO
ALTER DATABASE [Librarydatabase] SET  MULTI_USER 
GO
ALTER DATABASE [Librarydatabase] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Librarydatabase] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Librarydatabase] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Librarydatabase] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Librarydatabase] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Librarydatabase] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Librarydatabase', N'ON'
GO
ALTER DATABASE [Librarydatabase] SET QUERY_STORE = ON
GO
ALTER DATABASE [Librarydatabase] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Librarydatabase]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateFine]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateFine](@LoanID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @ReturnDate DATE, @CurrentDate DATE, @Fine DECIMAL(10, 2), @DaysOverdue INT;

    -- Get the return date of the loan
    SELECT @ReturnDate = ReturnDate 
    FROM Loans 
    WHERE LoanID = @LoanID;

    -- If the book has not been returned yet, use the current date
    IF @ReturnDate IS NULL
    BEGIN
        SET @ReturnDate = GETDATE(); -- current date
    END

    -- Calculate the days overdue
    SET @CurrentDate = GETDATE();
    IF @ReturnDate < @CurrentDate
    BEGIN
        SET @DaysOverdue = DATEDIFF(DAY, @ReturnDate, @CurrentDate);
    END
    ELSE
    BEGIN
        SET @DaysOverdue = 0;
    END

    -- Calculate the fine, $1 per overdue day
    SET @Fine = @DaysOverdue * 1.00;

    -- Return the fine amount (0 if not overdue)
    RETURN @Fine;
END;
GO
/****** Object:  Table [dbo].[Books]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[BookID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[AuthorID] [int] NOT NULL,
	[PublicationYear] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Members]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Members](
	[MemberID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[MembershipDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Loans]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loans](
	[LoanID] [int] IDENTITY(1,1) NOT NULL,
	[BookID] [int] NOT NULL,
	[MemberID] [int] NOT NULL,
	[LoanDate] [date] NOT NULL,
	[ReturnDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[LoanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[LoanHistory]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LoanHistory] AS
SELECT 
    m.Name AS MemberName,
    b.Title AS BookTitle,
    l.LoanDate,
    l.ReturnDate
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID;
GO
/****** Object:  Table [dbo].[Authors]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Authors](
	[AuthorID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AuthorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[BookBorrowCount]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BookBorrowCount] AS
SELECT 
    b.Title AS BookTitle,
    a.Name AS AuthorName,
    COUNT(l.LoanID) AS TotalBorrowedCount
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
LEFT JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.BookID, b.Title, a.Name;
GO
/****** Object:  Table [dbo].[BooksAudit]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BooksAudit](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[BookID] [int] NULL,
	[Title] [nvarchar](200) NULL,
	[AuthorID] [int] NULL,
	[PublicationYear] [int] NULL,
	[ActionType] [nvarchar](50) NULL,
	[ChangeDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Books]  WITH CHECK ADD FOREIGN KEY([AuthorID])
REFERENCES [dbo].[Authors] ([AuthorID])
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
/****** Object:  StoredProcedure [dbo].[AddAuthor]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddAuthor] 
    @AuthorName NVARCHAR(100)
AS
BEGIN
    INSERT INTO Authors (Name)
    VALUES (@AuthorName);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddBook]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddBook]
    @Title NVARCHAR(200),
    @AuthorID INT,
    @PublicationYear INT
AS
BEGIN
    INSERT INTO Books (Title, AuthorID, PublicationYear)
    VALUES (@Title, @AuthorID, @PublicationYear);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddLoan]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddLoan]
    @BookID INT,
    @MemberID INT,
    @LoanDate DATE,
    @ReturnDate DATE = NULL
AS
BEGIN
    INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate)
    VALUES (@BookID, @MemberID, @LoanDate, @ReturnDate);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddMember]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddMember]
    @MemberName NVARCHAR(100),
    @MembershipDate DATE
AS
BEGIN
    INSERT INTO Members (Name, MembershipDate)
    VALUES (@MemberName, @MembershipDate);
END;
GO
/****** Object:  StoredProcedure [dbo].[GetMemberDetails]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMemberDetails]
    @MemberID INT
AS
BEGIN
    -- Retrieve member details
    SELECT 
        m.MemberID,
        m.Name AS MemberName,
        m.MembershipDate
    FROM Members m
    WHERE m.MemberID = @MemberID;
    
    -- Retrieve loan history
    SELECT 
        l.LoanID,
        b.Title AS BookTitle,
        l.LoanDate,
        l.ReturnDate
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    WHERE l.MemberID = @MemberID
    ORDER BY l.LoanDate DESC;
    
    -- Retrieve current overdue books
    SELECT 
        b.Title AS BookTitle,
        l.LoanDate,
        DATEDIFF(DAY, l.LoanDate, GETDATE()) AS OverdueDays
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    WHERE l.MemberID = @MemberID AND l.ReturnDate IS NULL
    AND DATEDIFF(DAY, l.LoanDate, GETDATE()) > 14;  -- Overdue books (14 days or more)
END;
GO
/****** Object:  StoredProcedure [dbo].[GetOverdueBooks]    Script Date: 18-12-2024 12:51:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetOverdueBooks]
AS
BEGIN
    SELECT 
        b.Title AS BookTitle,
        m.Name AS MemberName,
        l.LoanDate,
        DATEDIFF(DAY, l.LoanDate, GETDATE()) AS OverdueDays,
        DATEDIFF(DAY, l.LoanDate, GETDATE()) * 1 AS FineAmount -- Assuming 1 unit per day fine
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    JOIN Members m ON l.MemberID = m.MemberID
    WHERE l.ReturnDate IS NULL
    AND DATEDIFF(DAY, l.LoanDate, GETDATE()) > 14 -- Overdue books (14 days or more)
    ORDER BY OverdueDays DESC;
END;
GO
USE [master]
GO
ALTER DATABASE [Librarydatabase] SET  READ_WRITE 
GO
