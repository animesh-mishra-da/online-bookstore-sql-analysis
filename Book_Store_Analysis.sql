Drop Table if Exists Books;
Create Table Books(
		Book_Id	int Primary Key,
		Title varchar(100),
		Author varchar (50),
		Genre varchar(20),
		Published_Year int,
		Price numeric (10,2),
		Stock int
);

Drop Table if Exists Customers;
Create Table Customers(
		Customer_Id int	Primary Key,
		Name varchar(100),
		Email varchar(100),
		Phone int,
		City varchar(50),
		Country varchar(100)
);

Drop Table if Exists Orders;
Create Table Orders(
		Order_Id int PRimary Key,
		Customer_Id int,
		Book_Id int,
		Order_Date date,
		Quantity int,
		Total_Amount numeric (10,2)
);

Select * from Books;
Select * from Customers;
Select * from Orders;

--Import data into Books Table
Copy Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock)
From 'D:\Users\Dell\Downloads\Practice Files SQL Projects\Practice Files SQL Projects\Books.csv'
CSV Header
Delimiter ',';

--Import data into Customers Table\
Copy Customers(Customer_ID, Name, Email, Phone, City, Country)
From 'D:\Users\Dell\Downloads\Practice Files SQL Projects\Practice Files SQL Projects\Customers.csv'
CSV Header
Delimiter ',';

--Import data into Orders Table
Copy Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount)
From 'D:\Users\Dell\Downloads\Practice Files SQL Projects\Practice Files SQL Projects\Orders.csv'
CSV Header
Delimiter ',';

--Basic Query 
--1) Retrieve all books in the "Fiction" genre
Select *
From Books
Where genre='Fiction';

--2) Find books published after the year 1950
Select * 
From Books 
Where Published_year >=1950;

--3) List all customers from the Canada
Select *
From Customers
Where Country = 'Canada';

--4) Show orders placed in November 2023
Select *
From Orders
Where Order_Date Between '2023-11-01' And '2023-11-30';

--5) Retrieve the total stock of books available
Select Sum(Stock) As Total_Stock
From Books;

--6) Find the details of the most expensive book
Select *
From Books 
Order by Price Desc
Limit 1;

--7) Show all customers who ordered more than 1 quantity of a book
Select *
From Orders 
Where Quantity > 1;

Select c.Customer_Id, c.Name, b.Title, o.Order_Id, o.Quantity
From Customers As c
Join Orders As o on c.Customer_Id = o.Customer_Id
Join Books As b on o.Book_Id = b.Book_Id
Where o.Quantity > 1
Order By c.Customer_Id, o.Order_Id;

--8) Retrieve all orders where the total amount exceeds $20
Select *
From Orders
Where Total_Amount > 20;

--9) List all genres available in the Books table
Select Distinct Genre
From Books;

--10) Find the book with the lowest stock
Select *
From Books
Order By Stock
Limit 1; 

--11) Calculate the total revenue generated from all orders
Select Sum (Total_Amount) As Total_Revenue
From Orders;

--Advance Query
--1) Retrieve the total number of books sold for each genre
Select b.genre, Sum(o.Quantity) As Total_Books_Sold
From Orders o
Join Books b on o.book_id = b.book_id
Group by b.genre;

--2) Find the average price of books in the "Fantasy" genre
Select Avg(price) As Avg_Price
From Books
Where genre='Fantasy';

--3) List customers who have placed at least 2 orders
SELECT 
    c.Customer_ID,
    c.Name,
    COUNT(o.Order_Id) AS total_orders
FROM Customers AS c
JOIN Orders AS o ON c.Customer_ID = o.Customer_Id
GROUP BY c.Customer_ID, c.Name
HAVING COUNT(o.Order_Id) >= 2;

--4) Find the most frequently ordered book
Select * from Orders;

Select book_id, Count(order_id) As order_count
From orders
Group by book_id
Order By order_count Desc
Limit 1;

--5) Show the top 3 most expensive books of 'Fantasy' Genre 
Select * from Books;

Select book_id, title, genre, Price
From Books
Where genre = 'Fantasy'
Order by price Desc
Limit 3;

--6) Retrieve the total quantity of books sold by each author
Select * from Orders;
Select * from Books;

Select b.Author, b.book_id, Sum(o.quantity) As Total_Quantity
From books As b
Join orders As o on b.book_id = o.book_id
Group by b.Author, b.book_id
Order by Total_Quantity Desc;

--7) List the cities where customers who spent over $30 are located
Select * from Customers;
Select * from Orders;

SELECT DISTINCT c.city
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.total_amount > 30;

--8) Find the customer who spent the most on orders
Select * from Customers;
Select * from Orders;

Select c.customer_id, c.name, sum(total_amount) As Total_Spent
From orders As o
Join customers as c on c.customer_id = o.customer_id
Group by c.customer_id, c.name
order by Total_Spent Desc
Limit 3;

--9) Calculate the stock remaining after fulfilling all orders

Select b.book_id, b.title, b.stock, Coalesce (Sum(o.quantity),0) AS Order_Qantity,
b.stock - Coalesce (Sum(o.quantity),0) As Remaining_Quantity
From Books As b
Left Join Orders As o on b.book_id = o.book_id
Group By b.book_id
Order By b.book_id;

--10) Which author earns the most revenue in each genre? (CTE + RANK)

With author_sales As (
    Select b.Genre, b.Author,
           Sum(o.Quantity) As Total_Qty,
           Sum(o.total_amount) As Total_Revenue
    From Orders As o
    Join Books As b On o.Book_Id = b.Book_Id
    Group By b.Genre, b.Author
),
ranked As (
    Select *,
           Rank() Over (Partition By Genre Order By Total_Revenue Desc) As Revenue_Rank
    From author_sales
)
Select Genre, Author, Total_Qty, Total_Revenue, Revenue_Rank
From ranked
Where Revenue_Rank = 1
Order By Genre;

--11) Who are the top 3 customers by spending in each country? (CTE + ROW_NUMBER)

WITH Customer_Spent AS (
    Select c.customer_id, c.name, c.country,
           SUM(o.Total_Amount) AS Total_Spent
    FROM Customers AS c
    JOIN Orders AS o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.name, c.country
),
Ranked As(
	Select country, name, Total_Spent,
		Row_Number() over (Partition by Country Order by Total_Spent Desc) As Rank_In_Country
From Customer_Spent
)
Select Country, name, Total_Spent, Rank_In_Country
From Ranked
Where Rank_In_Country <=3
Order By Country, Rank_In_Country;
