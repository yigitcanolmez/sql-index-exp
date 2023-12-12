-- TABLO OLUŞTURMA

CREATE TABLE Person(
Id int,
FirstName varchar(255),
LastName varchar(255),
Salary int 
);

SELECT * FROM Person; --tablonun oluştuğunu görelim

--şimdide içerisine kayıt atalım

INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (1, 'Yiğitcan', 'Ölmez', '1907');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (2, 'Mert', 'Ölmez', '2800');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (3, 'Edin','Dzeko', '3200');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (4, 'Sebastian', 'Szymanski', '2700');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (5, 'Dusan', 'Tadic', '5500');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (6, 'Dominik', 'Livakovic', '4000');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (7, 'Fred', 'Rodrigues', '3870');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (8, 'Rade', 'Krunic', '2500');


-- atılan kayıtları görelim
SELECT * FROM Person order by salary desc;

SELECT * FROM Person p WHERE Salary BETWEEN 2500 AND 3500;

CREATE INDEX IX_Person_Salary
on Person (Salary ASC); --IX prefix'i, index olduğunu belirtmek için kullanılmıştır.

select * from Person p ;

sp_Helpindex Person;

DROP INDEX Person.IX_Person_Salary;































