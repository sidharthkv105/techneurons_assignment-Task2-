--View to Show a Consolidated View of Loan History
CREATE VIEW LoanHistory AS
SELECT 
    m.Name AS MemberName,
    b.Title AS BookTitle,
    l.LoanDate,
    l.ReturnDate
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID;

--View to Display Books Along with Their Authors and Total Borrowed Count
CREATE VIEW BookBorrowCount AS
SELECT 
    b.Title AS BookTitle,
    a.Name AS AuthorName,
    COUNT(l.LoanID) AS TotalBorrowedCount
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID
LEFT JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.BookID, b.Title, a.Name;
