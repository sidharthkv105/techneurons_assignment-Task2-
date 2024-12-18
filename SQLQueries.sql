-- List all books currently on loan (i.e., ReturnDate is NULL)
SELECT b.BookID, b.Title, b.PublicationYear, m.Name AS MemberName, l.LoanDate
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL;

-- Find the most borrowed author 
SELECT TOP 1 a.Name AS AuthorName, COUNT(DISTINCT l.BookID) AS TotalBooksBorrowed
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Authors a ON b.AuthorID = a.AuthorID
WHERE l.ReturnDate IS NOT NULL  
GROUP BY a.Name
ORDER BY TotalBooksBorrowed DESC;

-- Retrieve members with overdue books
SELECT m.Name AS MemberName, b.Title AS BookTitle, l.LoanDate, l.ReturnDate
FROM Loans l
JOIN Members m ON l.MemberID = m.MemberID
JOIN Books b ON l.BookID = b.BookID
WHERE l.ReturnDate < GETDATE() 
AND l.ReturnDate IS NOT NULL;
