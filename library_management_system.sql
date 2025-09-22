-- 0. CREATE A LIBRARY MANAGEMENT SYSTEM DATABASE
-- Use whatever database name you desire
CREATE DATABASE IF NOT EXISTS bookieLibrary;
USE bookieLibrary;

-- Then, CREATE THE TABLES FOR THE LIBRARY MANAGEMENT SYSTEM

-- LOOKUP TABLES (Statuses, Types)

-- 1. Membership Types Table
CREATE TABLE IF NOT EXISTS membershipTypes (
    membershipTypeID INT PRIMARY KEY AUTO_INCREMENT,
    typeName VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- 2. Membership Status Table
CREATE TABLE IF NOT EXISTS memberStatus (
    statusID INT PRIMARY KEY AUTO_INCREMENT,
    statusName VARCHAR(20) UNIQUE NOT NULL
);

-- 3. Book Status Table for BookCopies Table
CREATE TABLE IF NOT EXISTS bookStatuses (
    statusID INT PRIMARY KEY AUTO_INCREMENT,
    statusName VARCHAR(20) UNIQUE NOT NULL
);

-- 4. BorrowTransaction Status Table
CREATE TABLE IF NOT EXISTS borrowStatuses (
    statusID INT PRIMARY KEY AUTO_INCREMENT,
    statusName VARCHAR(20) NOT NULL UNIQUE
);

-- 5. ContributionType Table for BookAuthors Table
CREATE TABLE IF NOT EXISTS contributionTypes (
    contributionTypeID INT PRIMARY KEY AUTO_INCREMENT,
    typeName VARCHAR(30) NOT NULL UNIQUE
);


-- **************************************************
-- STAFFS, ROLES, STAFF PROFILES TABLE
-- All Information About The Library Staffs
-- **************************************************

-- 6. Staffs Table
CREATE TABLE IF NOT EXISTS staffs(
	staffID INT PRIMARY KEY AUTO_INCREMENT, 
    employeeID VARCHAR(20) UNIQUE NOT NULL, 
    firstName VARCHAR(50) NOT NULL, 
    lastName VARCHAR(50) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL, 
    phoneNumber VARCHAR(20), 
    salary DECIMAL(10, 2), -- In Naira
    hire_date DATE,
    status ENUM('Active', 'Inactive', 'Terminated') DEFAULT 'Active' NOT NULL, 
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- CONSTRAINTS
    -- CONSTRAINT chk_hireDate CHECK (hire_date <= CURRENT_DATE),
    CONSTRAINT chk_salary CHECK (salary > 0),
    
    -- INDEXES
    INDEX idx_staffName (lastName, firstName),
    INDEX idx_employeeID (employeeID)
);

-- 7. Roles Table 
CREATE TABLE IF NOT EXISTS roles(
	roleID INT PRIMARY KEY AUTO_INCREMENT, 
    roleName VARCHAR(50) UNIQUE NOT NULL
);

-- 8. StaffRoles Table
CREATE TABLE IF NOT EXISTS staffRoles(
	staffID INT NOT NULL, 
    roleID INT NOT NULL, 
    assignedAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    isPrimary BOOLEAN DEFAULT FALSE, 
    isActive BOOLEAN DEFAULT TRUE, 
    
    -- Composite Primary Keys
    PRIMARY KEY (staffID, roleID), 
    
    -- FOREIGN KEYS    
    FOREIGN KEY (staffID) REFERENCES staffs(staffID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (roleID) REFERENCES roles(roleID) ON DELETE CASCADE ON UPDATE CASCADE, 
    
    -- INDEXES 
    INDEX idx_staffRoleDetail (isPrimary, staffID)
);

-- 9. StaffProfiles Table
CREATE TABLE IF NOT EXISTS staffProfiles (
    profileID INT AUTO_INCREMENT PRIMARY KEY,
    staffID INT UNIQUE NOT NULL,
    address TEXT,
    emergencyContactName VARCHAR(100),
    emergencyContactPhone VARCHAR(20),
    qualifications TEXT,
    department VARCHAR(50),
    
    -- FOREIGN KEY
    supervisorID INT, 
    
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- FOREIGN KEYS CONSTRAINTS    
    FOREIGN KEY (staffID) REFERENCES staffs(staffID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (supervisorID) REFERENCES staffs(staffID) ON DELETE SET NULL, 
    
    -- INDEXES
    INDEX idx_supervisor (supervisorID)
);

-- 10. Members Table
CREATE TABLE IF NOT EXISTS members(
	memberID INT PRIMARY KEY AUTO_INCREMENT, 
    membershipNumber VARCHAR(20) UNIQUE NOT NULL, 
    firstName VARCHAR(50) NOT NULL, 
    lastName VARCHAR(50) NOT NULL, 
    fullName VARCHAR(101) GENERATED ALWAYS AS (CONCAT(firstName, ' ', lastName)) STORED, 
    email VARCHAR(100) UNIQUE NOT NULL, 
    phoneNumber VARCHAR(20), 
    address TEXT, 
    dateOfBirth DATE, 
    join_date DATE DEFAULT (CURRENT_DATE) NOT NULL,
    
    -- ENUMERATIONS AS FK
    membershipTypeID INT NOT NULL,
    statusID INT NOT NULL,
    
    deletedAt TIMESTAMP NULL DEFAULT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- ENUMERATION FOREIGN KEYS
    createdBy INT, 
    updatedBy INT, 
    
    -- CONSTRAINTS
    -- CONSTRAINT chk_memberDOB CHECK (dateOfBirth < CURRENT_DATE), 
    -- CONSTRAINT chk_join_date CHECK (join_date <= CURRENT_DATE), 
    
    FOREIGN KEY (membershipTypeID) REFERENCES membershipTypes(membershipTypeID),
    FOREIGN KEY (statusID) REFERENCES memberStatus(statusID),
    FOREIGN KEY (createdBy) REFERENCES staffs(staffID),
    FOREIGN KEY (updatedBy) REFERENCES staffs(staffID),
    
    -- INDEXES
    INDEX idx_membersName (lastName, firstName), 
    INDEX idx_memberEmails (email)    
);

-- 11. Authors Table 
CREATE TABLE IF NOT EXISTS authors(
	authorID INT PRIMARY KEY AUTO_INCREMENT, 
    firstName VARCHAR(50), 
    lastName VARCHAR(50), 
    dateOfBirth DATE, 
    nationality VARCHAR(50), 
    biography TEXT, 
    email VARCHAR(100) UNIQUE NULL, 
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- CONSTRAINTS
    -- CONSTRAINT chk_authorDOB CHECK (dateOfBirth < CURRENT_DATE),
    
    -- INDEXES
    INDEX idx_authorName (lastName, firstName)
);

-- 12. Publishers Table
CREATE TABLE IF NOT EXISTS publishers(
	publisherID INT PRIMARY KEY AUTO_INCREMENT, 
    publisherName VARCHAR(100) UNIQUE NOT NULL, 
    phoneNumber VARCHAR(20), 
    address TEXT, 
    contact_email VARCHAR(100) UNIQUE, 
    website VARCHAR(100), 
    establishment_year YEAR, 
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- INDEXES
    INDEX idx_publisherDetails(publisherName, phoneNumber, contact_email, website)
);

-- **************************************************
-- CATEGORIES, BOOKS, BOOK COPIES, BOOK AUTHORS, BOOK LOCATION TABLES
-- All Information About Books in The Library
-- **************************************************

-- 13. Categories Table
CREATE TABLE IF NOT EXISTS categories(
	categoryID INT PRIMARY KEY AUTO_INCREMENT, 
    categoryName VARCHAR(100) UNIQUE NOT NULL, 
    description TEXT, 
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 14. Books Table
CREATE TABLE IF NOT EXISTS books(
	bookID INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(255) NOT NULL,  
    isbn VARCHAR(20) UNIQUE NOT NULL, 
    edition INT DEFAULT 1, 
    publication_year SMALLINT NOT NULL,      
    totalCopies INT NOT NULL DEFAULT 1, 
    availableCopies INT NOT NULL DEFAULT 1,
    bookPrice DECIMAL(10, 2) DEFAULT 0.00, 
    
    -- Foreign Keys
    publisherID INT, 
    categoryID INT, 
    createdBy INT,
    updatedBy INT,
    
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- CONSTRAINTS
    CONSTRAINT chk_copies CHECK (availableCopies >= 0 AND totalCopies > 0 AND availableCopies <= totalCopies),
    CONSTRAINT chk_edition CHECK (edition > 0),
    CONSTRAINT chk_price CHECK (bookPrice >= 0),
    
    FOREIGN KEY (publisherID) REFERENCES publishers(publisherID) ON DELETE SET NULL, 
    FOREIGN KEY (categoryID) REFERENCES categories(categoryID) ON DELETE SET NULL, 
    FOREIGN KEY (createdBy) REFERENCES staffs(staffID),
    FOREIGN KEY (updatedBy) REFERENCES staffs(staffID), 
    FOREIGN KEY (createdBy) REFERENCES staffs(staffID),
    FOREIGN KEY (updatedBy) REFERENCES staffs(staffID),
    
    -- INDEXES
    INDEX idx_bookTitle (title),
    INDEX idx_book_isbn (isbn),
    INDEX idx_pub_year (publication_year)
);

-- 15. Book Location Table
CREATE TABLE IF NOT EXISTS bookLocation (
  locationID INT PRIMARY KEY AUTO_INCREMENT ,
  branchName VARCHAR(100) NOT NULL,         -- e.g. "Main Library"
  floor VARCHAR(20),                        -- e.g. "2nd Floor"
  aisle VARCHAR(20),                        -- e.g. "Aisle 5"
  shelfCode VARCHAR(20),                    -- e.g. "B5"
  sectionName VARCHAR(50),                  -- e.g. "Reference Section"
  description TEXT, 
  
  -- INDEXES
  INDEX idx_bookLocation (branchName, floor, aisle, shelfCode)
);

-- 16. Book Copies Table
CREATE TABLE IF NOT EXISTS bookCopies(
	bookCopyID INT PRIMARY KEY AUTO_INCREMENT, 
    
    -- FOREIGN KEYS
    bookID INT NOT NULL, 
    locationID INT,
    
    acquisitionDate DATE NOT NULL, 
    conditionNote TEXT, 
    
    -- ENUMERATION FOREIGN KEY
    statusID INT NOT NULL, 
    createdBy INT,
    updatedBy INT,
    
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,    
    
    -- CONSTRAINTS
    -- CONSTRAINT chk_acquisition_date CHECK (acquisitionDate <= CURRENT_DATE),
    
    FOREIGN KEY (bookID) REFERENCES books(bookID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (locationID) REFERENCES bookLocation(locationID) ON DELETE SET NULL, 
    FOREIGN KEY (statusID) REFERENCES bookStatuses(statusID),
    FOREIGN KEY (createdBy) REFERENCES staffs(staffID),
    FOREIGN KEY (updatedBy) REFERENCES staffs(staffID),
    
    -- INDEXES
    INDEX idx_copy_book_status (bookID, statusID)
);

-- 17. BookAuthors Table
CREATE TABLE IF NOT EXISTS bookAuthors(
	-- FOREIGN KEYS 
    bookID INT,     
    authorID INT, 
    
    authorOrder INT NULL CHECK (authorOrder > 0), 
    
    -- ENUMERATION TABLE FOREIGN KEY
    contributionTypeID INT NOT NULL, 
    
    -- Composite Primary Key
    PRIMARY KEY (bookID, authorID),     
    
    -- FOREIGN KEYS CONSTRAINTS 
    FOREIGN KEY (bookID) REFERENCES books(bookID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (authorID) REFERENCES authors(authorID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (contributionTypeID) REFERENCES contributionTypes(contributionTypeID)
);

-- 18. Reservations Table
CREATE TABLE IF NOT EXISTS reservations(
	reservationID INT PRIMARY KEY AUTO_INCREMENT, 
    
    -- FOREIGN KEYS
    memberID INT NOT NULL, 
    bookID INT NOT NULL, 
    
    reservation_date DATE DEFAULT (CURRENT_DATE) NOT NULL, 
    expiry_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',

    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    
    -- CONSTRAINTS         
    CONSTRAINT chk_reservation_dates CHECK (expiry_date >= reservation_date), 
    
    FOREIGN KEY (memberID) REFERENCES members(memberID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (bookID) REFERENCES books(bookID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 19. Borrow Transactions Table
CREATE TABLE IF NOT EXISTS borrowTransactions(
	borrowID INT PRIMARY KEY AUTO_INCREMENT, 
    
    -- FOREIGN KEYS
    memberID INT NOT NULL, 
    bookCopyID INT NOT NULL, 
    reservationID INT , 
    staffID INT NOT NULL, 
    
    borrow_date DATE DEFAULT (CURRENT_DATE) NOT NULL, 
    due_date DATE NOT NULL, 
    return_date DATE DEFAULT NULL, 
    
    -- ENUMERATION FOREIGN KEY
    statusID INT NOT NULL, 
    createdBy INT, 
    updatedBy INT, 
    
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,    
    
    -- CONSTRAINTS
    CONSTRAINT unique_borrow_per_reservation UNIQUE(reservationID),
    CONSTRAINT chk_borrow_dates CHECK (due_date >= borrow_date),
    
    -- FOREIGN KEYS CONSTRAINTS
    FOREIGN KEY (memberID) REFERENCES members(memberID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (bookCopyID) REFERENCES bookCopies(bookCopyID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (reservationID) REFERENCES reservations(reservationID) ON DELETE SET NULL, 
    FOREIGN KEY (staffID) REFERENCES staffs(staffID) ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (statusID) REFERENCES borrowStatuses(statusID),
    FOREIGN KEY (createdBy) REFERENCES staffs(staffID),
    FOREIGN KEY (updatedBy) REFERENCES staffs(staffID),
        
    -- INDEXES
    INDEX idx_borrow_status_due (statusID, due_date)
);

-- 20. Overdue Penalties Table
CREATE TABLE IF NOT EXISTS overdue_penalties(
	penaltyID INT PRIMARY KEY AUTO_INCREMENT, 
    
    -- FOREIGN KEYS
    memberID INT NOT NULL, 
    bookCopyID INT NOT NULL,
    borrowID INT NOT NULL, 
    
    daysOverdue INT NOT NULL, 
    finePerDay DECIMAL(5, 2) DEFAULT 100, 
    totalFine DECIMAL (7, 2) GENERATED ALWAYS AS (daysOverdue * finePerDay) STORED, 
    hasPaid BOOLEAN DEFAULT FALSE, 
    
    -- FOREIGN KEYS CONSTRAINTS
    FOREIGN KEY (borrowID) REFERENCES borrowTransactions(borrowID) ON DELETE CASCADE, 
    FOREIGN KEY (memberID) REFERENCES members(memberID) ON DELETE CASCADE, 
    FOREIGN KEY (bookCopyID) REFERENCES bookCopies(bookCopyID) ON DELETE CASCADE, 
    
    -- INDEXES
    INDEX idx_penalties_member (memberID)
);

-- DROP TRIGGERS IF EXISTS TO PREVENT ERROR
DROP TRIGGER IF EXISTS trg_hire_date_insert;
DROP TRIGGER IF EXISTS trg_hire_date_update;
DROP TRIGGER IF EXISTS trg_member_dob;
DROP TRIGGER IF EXISTS trg_member_join_date;
DROP TRIGGER IF EXISTS trg_author_dob;
DROP TRIGGER IF EXISTS trg_copy_acquisition_date;
DROP TRIGGER IF EXISTS trg_reservation_dates;
DROP TRIGGER IF EXISTS trg_borrow_dates;

-- ***************************************************
-- TRIGGERS FOR ALL TABLES USING THE CURRENT_DATE CONSTRAINTS
-- CURRENT_DATE IS A NON-DETERMINISTIC CONSTRAINT
-- ***************************************************

-- Make sure delimiter is set correctly
DELIMITER $$

-- A. TRIGGER: Staff hire date must not be in the future
CREATE TRIGGER trg_hire_date_insert
BEFORE INSERT ON staffs
FOR EACH ROW
BEGIN
  IF NEW.hire_date > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hire date cannot be in the future.';
  END IF;
END$$

-- B. TRIGGER
CREATE TRIGGER trg_hire_date_update
BEFORE UPDATE ON staffs
FOR EACH ROW
BEGIN
  IF NEW.hire_date > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hire date cannot be in the future.';
  END IF;
END$$

-- C. TRIGGER: Member DOB must be in the past
CREATE TRIGGER trg_member_dob
BEFORE INSERT ON members
FOR EACH ROW
BEGIN
  IF NEW.dateOfBirth >= CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth must be in the past.';
  END IF;
END$$

-- D. TRIGGER: Member join date cannot be in the future
CREATE TRIGGER trg_member_join_date
BEFORE INSERT ON members
FOR EACH ROW
BEGIN
  IF NEW.join_date > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Join date cannot be in the future.';
  END IF;
END$$

-- E. TRIGGER: Author DOB must be in the past
CREATE TRIGGER trg_author_dob
BEFORE INSERT ON authors
FOR EACH ROW
BEGIN
  IF NEW.dateOfBirth > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Author date of birth must be in the past.';
  END IF;
END$$

-- F. TRIGGER: Acquisition date must not be in the future
CREATE TRIGGER trg_copy_acquisition_date
BEFORE INSERT ON bookCopies
FOR EACH ROW
BEGIN
  IF NEW.acquisitionDate > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acquisition date cannot be in the future.';
  END IF;
END$$



-- *******************************************************
-- TRIGGER: Ensure borrow exists when reservation is marked 'collected' 
-- TRIGGER: Reservation expiry must be on or after reservation date
-- *******************************************************
-- G. TRIGGER
CREATE TRIGGER trg_reservation_dates
BEFORE INSERT ON reservations
FOR EACH ROW
BEGIN
  IF NEW.expiry_date < NEW.reservation_date THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expiry date must be after or equal to reservation date.';
  END IF;
END$$

-- H. TRIGGER: Borrow due date must be after or equal to borrow date
CREATE TRIGGER trg_borrow_dates
BEFORE INSERT ON borrowTransactions
FOR EACH ROW
BEGIN
  IF NEW.due_date < NEW.borrow_date THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Due date must be after or equal to borrow date.';
  END IF;
END$$

DELIMITER ;





-- ***********************************
-- SAMPLE DATA INSERTION
-- ***********************************

-- 1. Membership Types Table
INSERT INTO membershipTypes (membershipTypeID, typeName, description) VALUES
(1, 'Standard', 'Basic access to borrow books and use library facilities'),
(2, 'Premium', 'Extended borrow time and access to exclusive collections'),
(3, 'Student', 'Discounted plan for students with valid ID'),
(4, 'Senior', 'Special benefits for members aged 60 and above');


-- 2. Membership Status Table for Members.Status in Members Table
INSERT INTO memberStatus (statusID, statusName) VALUES
(1, 'Active'),
(2, 'Inactive'),
(3, 'Suspended'),
(4, 'Banned');


-- 3. Book Statuses Table 
INSERT INTO bookStatuses (statusID, statusName) VALUES
(1, 'Available'),
(2, 'Checked Out'),
(3, 'Reserved'),
(4, 'Lost'),
(5, 'Damaged'),
(6, 'In Repair');


-- 4. Borrow Statuses Table 
INSERT INTO borrowStatuses (statusID, statusName) VALUES
(1, 'Borrowed'),
(2, 'Returned'),
(3, 'Overdue'),
(4, 'Lost'),
(5, 'Renewed');


-- 5. Contribution Types Table(for Book Authors Table) 
INSERT INTO contributionTypes (contributionTypeID, typeName) VALUES
(1, 'Author'),
(2, 'Co-Author'),
(3, 'Editor'),
(4, 'Translator'),
(5, 'Illustrator'),
(6, 'Contributor');


-- 6. Staffs Table 
INSERT INTO staffs (
    staffID, employeeID, firstName, lastName, email, phoneNumber, salary, hire_date, status
) VALUES 
(1, 'EMP2023001', 'Aisha', 'Yusuf', 'aisha.yusuf@library.org', '08012345678', 150000.00, '2022-03-15', 'Active'),
(2, 'EMP2023002', 'Chinedu', 'Okafor', 'chinedu.okafor@library.org', '08023456789', 120000.00, '2021-07-10', 'Active'),
(3, 'EMP2023003', 'Fatima', 'Abdullahi', 'fatima.abdullahi@library.org', '08034567890', 100000.00, '2023-01-20', 'Inactive'),
(4, 'EMP2023004', 'Ifeanyi', 'Eze', 'ifeanyi.eze@library.org', '08045678901', 180000.00, '2020-05-01', 'Terminated'),
(5, 'EMP2023005', 'Grace', 'Johnson', 'grace.johnson@library.org', '08056789012', 130000.00, '2022-11-11', 'Active');


-- 7. Roles Table 
INSERT INTO roles (roleID, roleName) VALUES
(1, 'Librarian'),
(2, 'Assistant Librarian'),
(3, 'Administrator'),
(4, 'Archivist'),
(5, 'IT Support'),
(6, 'Front Desk Officer'),
(7, 'Cataloguer'),
(8, 'Security'),
(9, 'Cleaner'),
(10, 'Volunteer');


-- 8. StaffRoles Table
INSERT INTO staffRoles (staffID, roleID, assignedAt, isPrimary, isActive) VALUES
-- Aisha Yusuf - Librarian (primary)
(1, 1, '2022-03-15 09:00:00', TRUE, TRUE),

-- Chinedu Okafor - Assistant Librarian (primary)
(2, 2, '2021-07-11 10:00:00', TRUE, TRUE),

-- Fatima Abdullahi - Front Desk Officer (primary), Volunteer (secondary)
(3, 6, '2023-01-21 08:30:00', TRUE, TRUE),
(3, 10, '2023-01-25 14:00:00', FALSE, TRUE),

-- Ifeanyi Eze - IT Support (primary), Administrator (secondary, inactive)
(4, 5, '2020-05-02 11:00:00', TRUE, TRUE),
(4, 3, '2021-01-10 13:00:00', FALSE, FALSE),

-- Grace Johnson - Cataloguer (primary)
(5, 7, '2022-11-12 09:15:00', TRUE, TRUE);


-- 9. Staff Profiles Table 
INSERT INTO staffProfiles (
    profileID, staffID, address, emergencyContactName, emergencyContactPhone,
    qualifications, department, supervisorID
) VALUES
-- Aisha Yusuf (staffID 1) – She's the supervisor of others, so supervisorID is NULL
(1, 1, '12B Garki Road, Abuja', 'Yusuf Bako', '08011112222', 'MLS, BSc Library Science', 'Library Management', NULL),

-- Chinedu Okafor (staffID 2) – Supervised by Aisha
(2, 2, '45 Admiralty Way, Lagos', 'Ngozi Okafor', '08022223333', 'B.Ed, Diploma in Library Systems', 'Circulation', 1),

-- Fatima Abdullahi (staffID 3) – Supervised by Aisha
(3, 3, '78 Sardauna Crescent, Kano', 'Abdullahi Musa', '08033334444', 'BA English, Certified Library Assistant', 'Customer Service', 1),

-- Ifeanyi Eze (staffID 4) – Supervised by Aisha
(4, 4, '23 Onitsha Rd, Enugu', 'Nkechi Eze', '08044445555', 'BSc Computer Science, CCNA', 'IT Services', 1),

-- Grace Johnson (staffID 5) – Supervised by Aisha
(5, 5, '10 Allen Avenue, Ikeja', 'Peter Johnson', '08055556666', 'BSc Information Science', 'Cataloguing', 1);


-- 10. Members Table
INSERT INTO members (
    memberID, membershipNumber, firstName, lastName, email, phoneNumber, address,
    dateOfBirth, join_date, membershipTypeID, statusID, createdBy, updatedBy
) VALUES
-- Member 1: Active Standard Member
(1, 'MBR20230001', 'Samuel', 'Adeyemi', 'samuel.adeyemi@example.com', '08011112233', 
 '15 Unity Road, Lagos', '1990-06-15', '2023-09-01', 1, 1, 1, 1),

-- Member 2: Inactive Premium Member
(2, 'MBR20230002', 'Chiamaka', 'Okoro', 'chiamaka.okoro@example.com', '08022223344', 
 '27 Aba Crescent, Enugu', '1988-12-20', '2022-05-10', 2, 2, 2, 2),

-- Member 3: Suspended Student Member
(3, 'MBR20230003', 'Musa', 'Ibrahim', 'musa.ibrahim@example.com', '08033334455', 
 '9 Airport Road, Kano', '2000-04-05', '2023-02-14', 3, 3, 3, 3),

-- Member 4: Active Senior Member
(4, 'MBR20230004', 'Grace', 'Anyanwu', 'grace.anyanwu@example.com', '08044445566', 
 '42 Ogba Street, Abuja', '1955-11-25', '2024-01-09', 4, 1, 4, 4),

-- Member 5: Banned Premium Member
(5, 'MBR20230005', 'Tunde', 'Bakare', 'tunde.bakare@example.com', '08055556677', 
 '18 Oba Akinjobi Way, Ikeja', '1995-03-30', '2022-11-22', 2, 4, 5, 5);


-- 11. Authors Table
INSERT INTO authors (
    authorID, firstName, lastName, dateOfBirth, nationality, biography, email
) VALUES
-- Author 1: Nigerian author
(1, 'Chinua', 'Achebe', '1930-11-16', 'Nigerian', 
 'Chinua Achebe was a Nigerian novelist, poet, and critic, best known for his first novel "Things Fall Apart" (1958).', 
 'chinua.achebe@example.com'),

-- Author 2: British fantasy author
(2, 'J.K.', 'Rowling', '1965-07-31', 'British', 
 'British author best known for the Harry Potter fantasy series, which has sold over 500 million copies worldwide.', 
 'jk.rowling@example.com'),

-- Author 3: American author and activist
(3, 'Maya', 'Angelou', '1928-04-04', 'American', 
 'Maya Angelou was an American poet, memoirist, and civil rights activist.', 
 'maya.angelou@example.com'),

-- Author 4: Kenyan author
(4, 'Ngũgĩ', 'wa Thiong\'o', '1938-01-05', 'Kenyan', 
 'Ngũgĩ wa Thiong\'o is a Kenyan writer and academic who writes primarily in Gikuyu and is an advocate for African languages.', 
 'ngugi.thiongo@example.com'),

-- Author 5: Nigerian female author (no email)
(5, 'Buchi', 'Emecheta', '1944-07-21', 'Nigerian', 
 'Buchi Emecheta was a Nigerian-born British novelist who authored more than 20 books exploring themes of race, gender, and motherhood.', 
 NULL);
 
 
 -- 12. Publishers Table 
 INSERT INTO publishers (
    publisherID, publisherName, phoneNumber, address, contact_email, website, establishment_year
) VALUES
-- 1: Nigerian educational publisher
(1, 'University Press Plc', '08012345678', 'Three Crowns Building, Jericho, Ibadan, Nigeria', 
 'info@universitypressplc.com', 'https://www.universitypressplc.com', 1949),

-- 2: British international publisher
(2, 'Penguin Random House', '+44 20 7139 3000', '20 Vauxhall Bridge Road, London, UK', 
 'contact@penguinrandomhouse.co.uk', 'https://www.penguin.co.uk', 1935),

-- 3: Nigerian children’s book publisher
(3, 'Cassava Republic Press', '08023456789', 'Plot 2, Ganges Street, Maitama, Abuja', 
 'hello@cassavarepublic.biz', 'https://www.cassavarepublic.biz', 2006),

-- 4: American technology-focused publisher
(4, 'O\'Reilly Media', '+1 707-827-7000', '1005 Gravenstein Hwy North, Sebastopol, CA, USA', 
 'support@oreilly.com', 'https://www.oreilly.com', 1978),

-- 5: West African regional publisher
(5, 'Africa World Press', '+1 609-695-3200', 'The Africa Center, Trenton, New Jersey, USA', 
 'africaworld@africabooks.com', 'https://www.africaworldpressbooks.com', 1983);


-- 13. Categories Table
INSERT INTO categories (categoryID, categoryName, description) VALUES
(1, 'Fiction', 'Literary works based on imagination and creativity.'),
(2, 'Non-Fiction', 'Informative and factual books covering various subjects.'),
(3, 'Science Fiction', 'Fictional stories based on advanced science and technology.'),
(4, 'Biography', 'Detailed descriptions of a person’s life.'),
(5, 'Children’s Books', 'Books intended for a young audience, often with illustrations.'),
(6, 'Self-Help', 'Books designed to help readers solve personal problems.'),
(7, 'History', 'Books detailing historical events and analysis.'),
(8, 'Fantasy', 'Fiction with magical or supernatural elements.'),
(9, 'Romance', 'Books centered around romantic relationships.'),
(10, 'Mystery', 'Books focused on solving a crime or uncovering secrets.');


-- 14. Books Table
INSERT INTO books (
    bookID, title, isbn, edition, publication_year, totalCopies, availableCopies, bookPrice,
    publisherID, categoryID, createdBy, updatedBy
) VALUES
-- 1: Fiction Book
(1, 'Things Fall Apart', '9780385474542', 1, 1958, 10, 6, 2500.00, 
 1, 1, 1, 1),

-- 2: Fantasy Book
(2, 'Harry Potter and the Philosopher\'s Stone', '9780747532743', 1, 1997, 20, 15, 3500.00, 
2, 8, 2, 2),

-- 3: Biography
(3, 'I Know Why the Caged Bird Sings', '9780345514400', 1, 1969, 5, 3, 2800.00, 
3, 4, 3, 3),

-- 4: Self-Help
(4, 'The 7 Habits of Highly Effective People', '9780743269513', 3, 2004, 8, 5, 4000.00, 
4, 6, 4, 4),

-- 5: Children’s Book
(5, 'Chike and the River', '9780435905380', 1, 1966, 7, 7, 1800.00, 
1, 5, 5, 5),

-- 6: Science Fiction
(6, 'Dune', '9780441172719', 2, 1965, 12, 10, 4200.00, 
2, 3, 1, 2),

-- 7: Romance
(7, 'Pride and Prejudice', '9781503290563', 2, 1901, 3, 1, 900.00, 3, 4, 2, 2),

-- 8: History
(8, 'A Brief History of Time', '9780553380163', 1, 1988, 9, 6, 3800.00, 
4, 7, 3, 3),

-- 9: Non-Fiction
(9, 'Sapiens: A Brief History of Humankind', '9780062316097', 1, 2011, 11, 9, 5000.00, 
3, 2, 4, 4),

-- 10: Mystery
(10, 'The Da Vinci Code', '9780307474278', 1, 2003, 10, 8, 3700.00, 
2, 10, 5, 5);


-- 15. Book Location Table
INSERT INTO bookLocation (
    locationID, branchName, floor, aisle, shelfCode, sectionName, description
) VALUES
-- 1: Main Library, General Collection
(1, 'Main Library', '1st Floor', 'Aisle 1', 'A1', 'General Collection', 
 'Fiction and non-fiction books for general borrowing.'),

-- 2: Main Library, Children’s Section
(2, 'Main Library', 'Ground Floor', 'Aisle 3', 'C2', 'Children\'s Section', 
 'Books for kids aged 4–12 including picture books and early readers.'),

-- 3: Main Library, Reference
(3, 'Main Library', '2nd Floor', 'Aisle 5', 'R1', 'Reference Section', 
 'Encyclopedias, dictionaries, and non-circulating research materials.'),

-- 4: Science and Technology Annex
(4, 'Science Annex', '1st Floor', 'Aisle 2', 'S1', 'Technology', 
 'Books related to computing, engineering, and innovations.'),

-- 5: Humanities Branch
(5, 'Humanities Branch', '2nd Floor', 'Aisle 4', 'H3', 'History & Culture', 
 'Historical and cultural studies materials.'),

-- 6: Main Library, Archives
(6, 'Main Library', 'Basement', 'Aisle 7', 'AR1', 'Archives', 
 'Rare, old, and special collections — not for public circulation.'),

-- 7: Law Library Branch
(7, 'Law Library', 'Ground Floor', 'Aisle 1', 'L1', 'Legal Texts', 
 'Legal codes, casebooks, and law journals.'),

-- 8: Digital Media Center
(8, 'Digital Media Center', '1st Floor', 'Aisle D', 'DM2', 'E-Resources', 
 'Access points and guides for e-books, audiobooks, and online databases.'),

-- 9: Education Department Library
(9, 'Education Library', '2nd Floor', 'Aisle 6', 'ED4', 'Education', 
 'Books on teaching methodologies, pedagogy, and curriculum.'),

-- 10: Main Library, Self-Help Corner
(10, 'Main Library', '1st Floor', 'Aisle 8', 'SH1', 'Self-Help', 
 'Motivational books, self-development guides, and wellness materials.');


-- 16. Book Copies Table
INSERT INTO bookCopies (
    bookCopyID, bookID, locationID, acquisitionDate, conditionNote, 
    statusID, createdBy, updatedBy
) VALUES
-- Copy 1 of "Things Fall Apart"
(1, 1, 1, '2023-06-15', 'Good condition, minor cover wear.', 1, 1, 1),

-- Copy 2 of "Things Fall Apart"
(2, 1, 1, '2023-06-16', 'Excellent condition.', 1, 1, 1),

-- Copy 1 of "Harry Potter"
(3, 2, 2, '2022-11-02', 'Slightly worn spine, otherwise good.', 1, 2, 2),

-- Copy 2 of "Harry Potter"
(4, 2, 2, '2022-11-03', 'Cover damage, sent for repair.', 3, 2, 2),

-- Copy 1 of "I Know Why the Caged Bird Sings"
(5, 3, 3, '2021-09-10', 'Torn page in chapter 2.', 1, 3, 3),

-- Copy 1 of "The 7 Habits..."
(6, 4, 10, '2023-01-20', 'Slight highlighting in text.', 1, 4, 4),

-- Copy 1 of "Chike and the River"
(7, 5, 2, '2023-04-05', 'New copy.', 1, 5, 5),

-- Copy 2 of "Chike and the River"
(8, 5, 2, '2023-04-06', 'Pages bent, under observation.', 3, 5, 5),

-- Copy 1 of "Dune"
(9, 6, 4, '2022-07-25', 'Mint condition.', 1, 1, 2),

-- Copy 1 of "Pride and Prejudice"
(10, 7, 5, '2023-03-15', 'Some foxing on pages.', 1, 2, 1),

-- Copy 1 of "A Brief History of Time"
(11, 8, 6, '2020-10-01', 'In excellent condition.', 1, 3, 3),

-- Copy 1 of "Sapiens"
(12, 9, 7, '2021-12-10', 'Water damage on back cover.', 3, 4, 4),

-- Copy 1 of "The Da Vinci Code"
(13, 10, 10, '2022-02-08', 'Marked as lost.', 4, 5, 5);


-- 17. Book Authors Table
INSERT INTO bookAuthors (
    bookID, authorID, authorOrder, contributionTypeID
) VALUES
-- "Things Fall Apart" by Chinua Achebe
(1, 1, 1, 1),  -- Main Author

-- "Harry Potter and the Philosopher's Stone" by J.K. Rowling
(2, 2, 1, 1),

-- "I Know Why the Caged Bird Sings" by Maya Angelou
(3, 3, 1, 1),

-- "Chike and the River" by Chinua Achebe
(5, 1, 1, 1),

-- "The 7 Habits of Highly Effective People" by Stephen Covey (assume added as AuthorID 6 later)
-- Placeholder or skip for now if authorID 6 not created

-- "Dune" by Frank Herbert (assume added as AuthorID 6 or skip)

-- "Pride and Prejudice" by Jane Austen (assume authorID 6, or skip)

-- "Sapiens" by Yuval Noah Harari (assume authorID 6, or skip)

-- Multi-author book (e.g., hypothetical edited collection)
(9, 4, 1, 2),  -- Ngũgĩ wa Thiong’o as Editor
(9, 5, 2, 3);  -- Buchi Emecheta as Contributor


-- 18. Reservations Table
INSERT INTO reservations (
    reservationID, memberID, bookID, reservation_date, expiry_date, status
) VALUES
-- 1: Member 1 reserves Book 1
(1, 1, 1, '2025-09-20', '2025-09-25', 'Active'),

-- 2: Member 2 reserves Book 3
(2, 2, 3, '2025-09-18', '2025-09-23', 'Active'),

-- 3: Member 3 reserves Book 5
(3, 3, 5, '2025-09-19', '2025-09-24', 'Cancelled'),

-- 4: Member 4 reserves Book 2
(4, 4, 2, '2025-09-21', '2025-09-26', 'Active'),

-- 5: Member 5 reserves Book 9
(5, 5, 9, '2025-09-20', '2025-09-27', 'Completed');


-- 19. Borrow Transactions Table 
INSERT INTO borrowTransactions (
    borrowID, memberID, bookCopyID, reservationID, staffID, 
    borrow_date, due_date, return_date, 
    statusID, createdBy, updatedBy
) VALUES
-- Member 1 borrowed BookCopy 1 via Reservation 1
(1, 1, 1, 1, 2, '2025-09-22', '2025-09-29', NULL, 1, 2, 2),

-- Member 2 borrowed BookCopy 5 via Reservation 2
(2, 2, 5, 2, 3, '2025-09-22', '2025-09-28', NULL, 1, 3, 3),

-- Member 3 borrowed BookCopy 7 via Reservation 3 and already returned
(3, 3, 7, 3, 1, '2025-09-19', '2025-09-25', '2025-09-21', 2, 1, 1),

-- Member 4 borrowed BookCopy 3 via Reservation 4, overdue
(4, 4, 3, 4, 5, '2025-09-10', '2025-09-17', NULL, 3, 5, 5),

-- Member 5 borrowed BookCopy 12 via Reservation 5
(5, 5, 12, 5, 4, '2025-09-22', '2025-09-29', NULL, 1, 4, 4);


-- 20. Overdue Penalties Table 
INSERT INTO overdue_penalties (
    penaltyID, memberID, bookCopyID, borrowID, 
    daysOverdue, finePerDay, hasPaid
) VALUES
-- Member 4 was overdue by 5 days for BookCopy 3 (borrowID 4)
(1, 4, 3, 4, 5, 100.00, FALSE),

-- Member 3 had 3-day overdue but has paid
(2, 3, 7, 3, 3, 100.00, TRUE),

-- Member 2 returned book 7 days late
(3, 2, 5, 2, 7, 100.00, FALSE),

-- Member 5 was overdue by 10 days but paid
(4, 5, 12, 5, 10, 100.00, TRUE);





-- ******************************
-- VIEWS FOR COMMON QUERIES
-- ******************************

-- 1. Staff Details (e.g including Salary and Roles)
CREATE VIEW v_staff_salaries_roles AS
SELECT 
    s.staffID,
    s.employeeID,
    CONCAT(s.firstName, ' ', s.lastName) AS fullName,
    s.email,
    CONCAT('₦', FORMAT(s.salary, 2)) AS salary,
    r.roleName,
    sr.isPrimary,
    sr.isActive
FROM staffs s
INNER JOIN staffRoles sr ON s.staffID = sr.staffID
INNER JOIN roles r ON sr.roleID = r.roleID;


-- 2. Book Details Table (including Pricing and Availability, Publisher and Category Info) 
CREATE VIEW v_book_prices AS
SELECT 
    b.bookID,
    b.title,
    b.isbn,
    CONCAT('₦', FORMAT(b.bookPrice, 2)) AS bookPrice,
    b.totalCopies,
    b.availableCopies,
    c.categoryName,
    p.publisherName
FROM books b
LEFT JOIN categories c ON b.categoryID = c.categoryID
LEFT JOIN publishers p ON b.publisherID = p.publisherID;

-- 3. Overdue Penalties View with Members Info
CREATE VIEW v_overdue_penalties AS
SELECT 
    p.penaltyID,
    p.memberID,
    m.fullName,
    p.bookCopyID,
    p.borrowID,
    p.daysOverdue,
    CONCAT('₦', FORMAT(p.finePerDay, 2)) AS finePerDay,
    CONCAT('₦', FORMAT(p.totalFine, 2)) AS totalFine,
    p.hasPaid
FROM overdue_penalties p
INNER JOIN members m ON p.memberID = m.memberID;


-- 4. Borrow Transaction Details wihe Necessary Info
CREATE VIEW v_borrow_transactions_detailed AS
SELECT 
    bt.borrowID,
    m.fullName AS memberName,
    b.title AS bookTitle,
    bc.bookCopyID,
    bt.borrow_date,
    bt.due_date,
    bt.return_date,
    bs.statusName AS borrowStatus,
    CONCAT(s.firstName, ' ', s.lastName) AS processedBy
FROM borrowTransactions bt
INNER JOIN members m ON bt.memberID = m.memberID
INNER JOIN bookCopies bc ON bt.bookCopyID = bc.bookCopyID
INNER JOIN books b ON bc.bookID = b.bookID
INNER JOIN staffs s ON bt.staffID = s.staffID
INNER JOIN borrowStatuses bs ON bt.statusID = bs.statusID;


-- 5. Members Overview Details
CREATE VIEW v_members_overview AS
SELECT 
    m.memberID,
    m.membershipNumber,
    m.fullName,
    m.email,
    m.phoneNumber,
    mt.typeName AS membershipType,
    ms.statusName AS membershipStatus,
    m.join_date
FROM members m
INNER JOIN membershipTypes mt ON m.membershipTypeID = mt.membershipTypeID
INNER JOIN memberStatus ms ON m.statusID = ms.statusID;


-- 6. Reservations Details (with Members and Books Info)
CREATE VIEW v_active_reservations AS
SELECT 
    r.reservationID,
    r.memberID,
    m.fullName,
    r.bookID,
    b.title AS bookTitle,
    r.reservation_date,
    r.expiry_date,
    r.status
FROM reservations r
INNER JOIN members m ON r.memberID = m.memberID
INNER JOIN books b ON r.bookID = b.bookID
WHERE r.status = 'Active';


-- 7. Books with Authors and Publishers Details 
CREATE VIEW v_book_authors_details AS
SELECT 
    b.bookID,
    b.title,
    a.authorID,
    CONCAT(a.firstName, ' ', a.lastName) AS authorName,
    ct.typeName AS contributionType,
    ba.authorOrder
FROM bookAuthors ba
INNER JOIN books b ON ba.bookID = b.bookID
INNER JOIN authors a ON ba.authorID = a.authorID
INNER JOIN contributionTypes ct ON ba.contributionTypeID = ct.contributionTypeID
ORDER BY b.bookID, ba.authorOrder;



