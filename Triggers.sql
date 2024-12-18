-- Trigger to Automatically Update the ReturnDate When a Book is Marked as Returned
CREATE TRIGGER trg_UpdateReturnDate
ON Loans
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE ReturnDate IS NOT NULL)
    BEGIN
        UPDATE Loans
        SET ReturnDate = GETDATE() 
        WHERE LoanID IN (SELECT LoanID FROM inserted WHERE ReturnDate IS NOT NULL);
    END
END;

-- Trigger to Log Changes to the Books Table into an Audit Table
CREATE TRIGGER trg_BooksAudit
ON Books
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO BooksAudit (BookID, Title, AuthorID, PublicationYear, ActionType, ChangeDate)
        SELECT BookID, Title, AuthorID, PublicationYear, 'INSERT', GETDATE()
        FROM inserted;
    END

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO BooksAudit (BookID, Title, AuthorID, PublicationYear, ActionType, ChangeDate)
        SELECT BookID, Title, AuthorID, PublicationYear, 'UPDATE', GETDATE()
        FROM inserted;
    END

    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO BooksAudit (BookID, Title, AuthorID, PublicationYear, ActionType, ChangeDate)
        SELECT BookID, Title, AuthorID, PublicationYear, 'DELETE', GETDATE()
        FROM deleted;
    END
END;
