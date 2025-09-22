# week8_database_final_project

## Library Management System Database

### Overview

This repository contains the complete SQL schema and sample data for a **Library Management System** designed to manage memberships, books, staff, transactions, and related entities. The system supports detailed tracking of books, authors, categories, memberships, borrowing, reservations, penalties, and staff roles.

---

### Database Schema

The schema consists of the following key tables, each designed with proper normalization, constraints, and relationships:

| Table Name            | Purpose                                                                                     |
|----------------------|---------------------------------------------------------------------------------------------|
| `membershipTypes`     | Stores types of membership (e.g., Regular, Premium)                                        |
| `memberStatus`        | Status of members (e.g., Active, Suspended)                                                |
| `bookStatuses`        | Status for book copies (e.g., Available, Checked Out, In Repair)                           |
| `borrowStatuses`      | Status of borrowing transactions (e.g., Borrowed, Returned, Overdue)                      |
| `contributionTypes`   | Types of author contributions (e.g., Author, Editor)                                      |
| `staffs`              | Staff details including salary and hire date                                              |
| `roles`               | Roles assigned to staff members                                                           |
| `staffRoles`          | Many-to-many relation between staff and roles                                             |
| `staffProfiles`       | Extended staff details including supervisor references                                    |
| `members`             | Library members including membership type and status                                      |
| `authors`             | Book authors with biographical details                                                    |
| `publishers`          | Publishers of books                                                                       |
| `categories`          | Book categories                                                                           |
| `books`               | Books metadata and inventory details                                                     |
| `bookLocation`        | Physical location of book copies in branches                                             |
| `bookCopies`          | Copies of books with condition and status                                                |
| `bookAuthors`         | Relation between books and authors with contribution types                               |
| `reservations`        | Book reservations made by members                                                        |
| `borrowTransactions`  | Records of books borrowed, due dates, returns, and statuses                              |
| `overdue_penalties`   | Penalties applied for overdue book returns                                              |

---

### Design Considerations

#### 1. Constraints and Data Integrity

- **Date constraints**: Triggers and checks ensure dates are logical, e.g., `hire_date` cannot be in the future, `dateOfBirth` must be in the past, `publication_year` is within a valid range.
- **Foreign keys**: Relationships are strongly enforced to maintain referential integrity.
- **Unique constraints**: Ensure no duplication of unique fields such as emails, membership numbers, ISBNs, etc.
- **Enumerations**: Statuses and types use lookup tables to maintain consistent terminology and enforce valid states.

#### 2. Currency and Monetary Fields

- Monetary values such as `salary` in the `staffs` table and `bookPrice` or `totalFine` in penalty-related tables are stored as `DECIMAL` types.
- To clarify currency (Naira, ₦), **views** are recommended for display purposes, appending currency symbols or labels to relevant fields without changing raw data storage.

#### 3. Use of Views

Views are created for common and important queries to:

- Present monetary values with currency indication.
- Combine related tables to simplify user queries (e.g., showing staff details with roles).
- Format date fields or computed columns for easier reporting.

---

### Sample Data

- The repository contains sample insertions with **explicit primary keys** and consistent foreign key references.
- Data respects all constraints including triggers (e.g., no future hire dates or invalid `publication_year`).
- Sample data covers all tables to facilitate immediate testing and development.

---

### Common Queries and Views

#### Example Views:

- **Staff with Roles View**

  Combines staff details with their assigned roles, showing primary roles and active statuses.

- **Member Summary View**

  Shows member details along with membership type and status descriptions.

- **Book Inventory View**

  Combines book metadata, category, publisher, and current availability status.

- **Overdue Penalties View**

  Displays penalties with total fine amounts, clearly showing which are paid or outstanding, with currency.

---

### Getting Started

1. **Setup the Database**

   - Use a MySQL or compatible RDBMS instance.
   - Run the `CREATE TABLE` commands in order (due to foreign key dependencies).
   - Insert sample data as provided to ensure relational integrity.

2. **Apply Triggers and Constraints**

   - Implement any trigger logic manually if your RDBMS does not support declarative constraints.
   - Ensure triggers for date validations and default timestamps are active.

3. **Use Provided Views**

   - Create views to simplify querying.
   - Modify or extend views as per specific reporting needs.

---

### Notes

- If you intend to include historic publication years (before 1901), you must **change the datatype** of `publication_year` from `YEAR` to `SMALLINT` or `INT` to avoid out-of-range errors.
- Always ensure foreign key referenced IDs exist before insertion to avoid errors.
- Use the sample data as templates for inserting real data.

---

### Future Enhancements

- Implement role-based access control on views and tables.
- Add stored procedures for complex transactions (e.g., borrowing workflow).
- Expand penalty management for partial payments or waivers.
- Introduce audit logging for sensitive actions.

---

### Contact

For questions or contributions, please open an issue or submit a pull request.

---

**Thank you for using this Library Management System schema!**

