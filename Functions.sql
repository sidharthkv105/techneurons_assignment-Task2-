-- User-Defined Function to Calculate Fine for Overdue Books
CREATE FUNCTION CalculateFine(@LoanID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @ReturnDate DATE, @CurrentDate DATE, @Fine DECIMAL(10, 2), @DaysOverdue INT;
    SELECT @ReturnDate = ReturnDate 
    FROM Loans 
    WHERE LoanID = @LoanID;
    IF @ReturnDate IS NULL
    BEGIN
        SET @ReturnDate = GETDATE(); -- current date
    END

    SET @CurrentDate = GETDATE();
    IF @ReturnDate < @CurrentDate
    BEGIN
        SET @DaysOverdue = DATEDIFF(DAY, @ReturnDate, @CurrentDate);
    END
    ELSE
    BEGIN
        SET @DaysOverdue = 0;
    END

    SET @Fine = @DaysOverdue * 1.00;
    RETURN @Fine;
END;

-- eg query:
SELECT dbo.CalculateFine(36) AS FineAmount;
