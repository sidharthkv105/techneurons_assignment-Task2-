--1. Stored Procedure for Adding New Books, Authors, Members, and Loans
--a. Adding a New Author
CREATE PROCEDURE AddAuthor 
    @AuthorName NVARCHAR(100)
AS
BEGIN
    INSERT INTO Authors (Name)
    VALUES (@AuthorName);
END;

--b. Adding a New Book
CREATE PROCEDURE AddBook
    @Title NVARCHAR(200),
    @AuthorID INT,
    @PublicationYear INT
AS
BEGIN
    INSERT INTO Books (Title, AuthorID, PublicationYear)
    VALUES (@Title, @AuthorID, @PublicationYear);
END;

--c. Adding a New Member
CREATE PROCEDURE AddMember
    @MemberName NVARCHAR(100),
    @MembershipDate DATE
AS
BEGIN
    INSERT INTO Members (Name, MembershipDate)
    VALUES (@MemberName, @MembershipDate);
END;

--d. Adding a New Loan
CREATE PROCEDURE AddLoan
    @BookID INT,
    @MemberID INT,
    @LoanDate DATE,
    @ReturnDate DATE = NULL
AS
BEGIN
    INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate)
    VALUES (@BookID, @MemberID, @LoanDate, @ReturnDate);
END;

--2. Stored Procedure for Retrieving Details of a Specific Member
CREATE PROCEDURE GetMemberDetails
    @MemberID INT
AS
BEGIN
    SELECT 
        m.MemberID,
        m.Name AS MemberName,
        m.MembershipDate
    FROM Members m
    WHERE m.MemberID = @MemberID;
    
    SELECT 
        l.LoanID,
        b.Title AS BookTitle,
        l.LoanDate,
        l.ReturnDate
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    WHERE l.MemberID = @MemberID
    ORDER BY l.LoanDate DESC;
    
    SELECT 
        b.Title AS BookTitle,
        l.LoanDate,
        DATEDIFF(DAY, l.LoanDate, GETDATE()) AS OverdueDays
    FROM Loans l
    JOIN Books b ON l.BookID = b.BookID
    WHERE l.MemberID = @MemberID AND l.ReturnDate IS NULL
    AND DATEDIFF(DAY, l.LoanDate, GETDATE()) > 14;  -- Overdue books (14 days or more)
END;

--3. Stored Procedure for Retrieving All Overdue Books
CREATE PROCEDURE GetOverdueBooks
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
