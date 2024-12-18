CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    AuthorID INT NOT NULL,
    PublicationYear INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

CREATE TABLE Members (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    MembershipDate DATE NOT NULL
);

CREATE TABLE Loans (
    LoanID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    MemberID INT NOT NULL,
    LoanDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

CREATE TABLE BooksAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT,
    Title NVARCHAR(200),
    AuthorID INT,
    PublicationYear INT,
    ActionType NVARCHAR(50),  -- Action type: 'INSERT', 'UPDATE', 'DELETE'
    ChangeDate DATETIME
);
