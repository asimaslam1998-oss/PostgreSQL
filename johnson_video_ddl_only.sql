-- Johnson Video Store - DDL ONLY (PostgreSQL)
-- Run this file first.

BEGIN;

DROP TABLE IF EXISTS oscar CASCADE;
DROP TABLE IF EXISTS movie_person CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS discount CASCADE;
DROP TABLE IF EXISTS charge CASCADE;
DROP TABLE IF EXISTS rental CASCADE;
DROP TABLE IF EXISTS movie_distributor CASCADE;
DROP TABLE IF EXISTS copy CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS distributor CASCADE;
DROP TABLE IF EXISTS movie CASCADE;
DROP TABLE IF EXISTS genre CASCADE;

CREATE TABLE genre (
  genre_id SERIAL PRIMARY KEY,
  genre_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE movie (
  movie_id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  rating VARCHAR(10),
  year_released INT CHECK (year_released BETWEEN 1900 AND 2100),
  runtime_min INT CHECK (runtime_min BETWEEN 1 AND 600),
  genre_id INT REFERENCES genre(genre_id),
  catalog_movie_code VARCHAR(40) UNIQUE
);

CREATE TABLE distributor (
  distributor_id SERIAL PRIMARY KEY,
  name VARCHAR(120) UNIQUE NOT NULL,
  phone VARCHAR(25),
  email VARCHAR(120) UNIQUE,
  address VARCHAR(200)
);

CREATE TABLE customer (
  customer_id SERIAL PRIMARY KEY,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  address VARCHAR(200),
  phone VARCHAR(25),
  email VARCHAR(120) UNIQUE
);

CREATE TABLE copy (
  copy_id SERIAL PRIMARY KEY,
  movie_id INT NOT NULL REFERENCES movie(movie_id),
  format VARCHAR(10) NOT NULL CHECK (format IN ('DVD','BLURAY','VHS')),
  store_tag_no VARCHAR(30) UNIQUE NOT NULL,
  distributor_serial_no VARCHAR(40) UNIQUE,
  status VARCHAR(15) NOT NULL CHECK (status IN ('in','out','lost','damaged'))
);

CREATE TABLE movie_distributor (
  movie_id INT NOT NULL REFERENCES movie(movie_id),
  distributor_id INT NOT NULL REFERENCES distributor(distributor_id),
  format VARCHAR(10) NOT NULL CHECK (format IN ('DVD','BLURAY','VHS')),
  wholesale_price NUMERIC(10,2) NOT NULL CHECK (wholesale_price >= 0),
  catalog_price_code VARCHAR(20),
  PRIMARY KEY (movie_id, distributor_id, format)
);

CREATE TABLE rental (
  rental_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customer(customer_id),
  copy_id INT NOT NULL REFERENCES copy(copy_id),
  rental_date DATE NOT NULL,
  due_date DATE NOT NULL,
  return_date DATE,
  CHECK (due_date >= rental_date),
  CHECK (return_date IS NULL OR return_date >= rental_date)
);

CREATE TABLE charge (
  charge_id SERIAL PRIMARY KEY,
  rental_id INT NOT NULL REFERENCES rental(rental_id) ON DELETE CASCADE,
  charge_type VARCHAR(20) NOT NULL CHECK (charge_type IN ('base','late','damage','rewind','tax')),
  amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  tax_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
  charge_date DATE NOT NULL
);

CREATE TABLE discount (
  discount_id SERIAL PRIMARY KEY,
  scope VARCHAR(10) NOT NULL CHECK (scope IN ('movie','genre')),
  movie_id INT REFERENCES movie(movie_id),
  genre_id INT REFERENCES genre(genre_id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  discount_pct NUMERIC(5,2) NOT NULL CHECK (discount_pct BETWEEN 0 AND 100),
  CHECK (end_date >= start_date),
  CONSTRAINT discount_scope_ck CHECK (
    (scope='movie' AND movie_id IS NOT NULL AND genre_id IS NULL)
    OR
    (scope='genre' AND genre_id IS NOT NULL AND movie_id IS NULL)
  )
);

CREATE TABLE person (
  person_id SERIAL PRIMARY KEY,
  full_name VARCHAR(120) UNIQUE NOT NULL,
  person_type VARCHAR(20) NOT NULL CHECK (person_type IN ('actor','actress','director','writer','producer'))
);

CREATE TABLE movie_person (
  movie_id INT NOT NULL REFERENCES movie(movie_id),
  person_id INT NOT NULL REFERENCES person(person_id),
  role VARCHAR(30) NOT NULL,
  PRIMARY KEY (movie_id, person_id, role)
);

CREATE TABLE oscar (
  oscar_id SERIAL PRIMARY KEY,
  oscar_year INT NOT NULL CHECK (oscar_year BETWEEN 1929 AND 2100),
  category VARCHAR(80) NOT NULL,
  result VARCHAR(10) NOT NULL CHECK (result IN ('won','nominated')),
  movie_id INT REFERENCES movie(movie_id),
  person_id INT REFERENCES person(person_id),
  CONSTRAINT oscar_target_ck CHECK (
    (movie_id IS NOT NULL AND person_id IS NULL) OR (person_id IS NOT NULL AND movie_id IS NULL)
  )
);

COMMIT;
-- Johnson Video Store - DML (Seed Data)
-- Run AFTER the DDL ONLY file.

BEGIN;

INSERT INTO genre (genre_name) VALUES
('Genre 01'),
('Genre 02'),
('Genre 03'),
('Genre 04'),
('Genre 05'),
('Genre 06'),
('Genre 07'),
('Genre 08'),
('Genre 09'),
('Genre 10'),
('Genre 11'),
('Genre 12'),
('Genre 13'),
('Genre 14'),
('Genre 15'),
('Genre 16'),
('Genre 17'),
('Genre 18'),
('Genre 19'),
('Genre 20');

INSERT INTO movie (title, rating, year_released, runtime_min, genre_id, catalog_movie_code) VALUES
('Movie Title 01', 'G', 2008, 149, 13, 'CAT0001'),
('Movie Title 02', 'PG-13', 2019, 167, 17, 'CAT0002'),
('Movie Title 03', 'NC-17', 2014, 89, 13, 'CAT0003'),
('Movie Title 04', 'NC-17', 2017, 85, 17, 'CAT0004'),
('Movie Title 05', 'G', 2019, 107, 16, 'CAT0005'),
('Movie Title 06', 'PG', 2016, 87, 7, 'CAT0006'),
('Movie Title 07', 'PG', 2008, 170, 19, 'CAT0007'),
('Movie Title 08', 'PG', 2006, 98, 12, 'CAT0008'),
('Movie Title 09', 'NC-17', 1996, 169, 19, 'CAT0009'),
('Movie Title 10', 'NC-17', 2019, 103, 16, 'CAT0010'),
('Movie Title 11', 'PG-13', 2018, 89, 6, 'CAT0011'),
('Movie Title 12', 'PG', 2000, 178, 3, 'CAT0012'),
('Movie Title 13', 'NC-17', 2011, 83, 1, 'CAT0013'),
('Movie Title 14', 'G', 2013, 129, 17, 'CAT0014'),
('Movie Title 15', 'PG', 2009, 110, 6, 'CAT0015'),
('Movie Title 16', 'NC-17', 2009, 96, 12, 'CAT0016'),
('Movie Title 17', 'NC-17', 1992, 154, 13, 'CAT0017'),
('Movie Title 18', 'R', 1996, 138, 10, 'CAT0018'),
('Movie Title 19', 'PG', 2007, 91, 12, 'CAT0019'),
('Movie Title 20', 'PG', 1997, 179, 20, 'CAT0020');

INSERT INTO distributor (name, phone, email, address) VALUES
('Distributor 01', '555-0101-0000', 'dist01@example.com', '101 Warehouse Rd'),
('Distributor 02', '555-0102-0000', 'dist02@example.com', '102 Warehouse Rd'),
('Distributor 03', '555-0103-0000', 'dist03@example.com', '103 Warehouse Rd'),
('Distributor 04', '555-0104-0000', 'dist04@example.com', '104 Warehouse Rd'),
('Distributor 05', '555-0105-0000', 'dist05@example.com', '105 Warehouse Rd'),
('Distributor 06', '555-0106-0000', 'dist06@example.com', '106 Warehouse Rd'),
('Distributor 07', '555-0107-0000', 'dist07@example.com', '107 Warehouse Rd'),
('Distributor 08', '555-0108-0000', 'dist08@example.com', '108 Warehouse Rd'),
('Distributor 09', '555-0109-0000', 'dist09@example.com', '109 Warehouse Rd'),
('Distributor 10', '555-0110-0000', 'dist10@example.com', '110 Warehouse Rd'),
('Distributor 11', '555-0111-0000', 'dist11@example.com', '111 Warehouse Rd'),
('Distributor 12', '555-0112-0000', 'dist12@example.com', '112 Warehouse Rd'),
('Distributor 13', '555-0113-0000', 'dist13@example.com', '113 Warehouse Rd'),
('Distributor 14', '555-0114-0000', 'dist14@example.com', '114 Warehouse Rd'),
('Distributor 15', '555-0115-0000', 'dist15@example.com', '115 Warehouse Rd'),
('Distributor 16', '555-0116-0000', 'dist16@example.com', '116 Warehouse Rd'),
('Distributor 17', '555-0117-0000', 'dist17@example.com', '117 Warehouse Rd'),
('Distributor 18', '555-0118-0000', 'dist18@example.com', '118 Warehouse Rd'),
('Distributor 19', '555-0119-0000', 'dist19@example.com', '119 Warehouse Rd'),
('Distributor 20', '555-0120-0000', 'dist20@example.com', '120 Warehouse Rd');

INSERT INTO customer (first_name, last_name, address, phone, email) VALUES
('Asim', 'Aslam', '201 Main St', '555-0201-0000', 'cust01@example.com'),
('Mia', 'Johnson', '202 Main St', '555-0202-0000', 'cust02@example.com'),
('Noah', 'Smith', '203 Main St', '555-0203-0000', 'cust03@example.com'),
('Olivia', 'Garcia', '204 Main St', '555-0204-0000', 'cust04@example.com'),
('Liam', 'Brown', '205 Main St', '555-0205-0000', 'cust05@example.com'),
('Emma', 'Davis', '206 Main St', '555-0206-0000', 'cust06@example.com'),
('Ava', 'Miller', '207 Main St', '555-0207-0000', 'cust07@example.com'),
('Sophia', 'Wilson', '208 Main St', '555-0208-0000', 'cust08@example.com'),
('Ethan', 'Moore', '209 Main St', '555-0209-0000', 'cust09@example.com'),
('Isabella', 'Taylor', '210 Main St', '555-0210-0000', 'cust10@example.com'),
('Lucas', 'Anderson', '211 Main St', '555-0211-0000', 'cust11@example.com'),
('Amelia', 'Thomas', '212 Main St', '555-0212-0000', 'cust12@example.com'),
('Mason', 'Jackson', '213 Main St', '555-0213-0000', 'cust13@example.com'),
('Harper', 'White', '214 Main St', '555-0214-0000', 'cust14@example.com'),
('Logan', 'Harris', '215 Main St', '555-0215-0000', 'cust15@example.com'),
('Evelyn', 'Martin', '216 Main St', '555-0216-0000', 'cust16@example.com'),
('James', 'Thompson', '217 Main St', '555-0217-0000', 'cust17@example.com'),
('Abigail', 'Lee', '218 Main St', '555-0218-0000', 'cust18@example.com'),
('Elijah', 'Perez', '219 Main St', '555-0219-0000', 'cust19@example.com'),
('Emily', 'Clark', '220 Main St', '555-0220-0000', 'cust20@example.com');

INSERT INTO copy (movie_id, format, store_tag_no, distributor_serial_no, status) VALUES
(1, 'DVD', 'T01-1', 'S011X2548', 'in'),
(1, 'BLURAY', 'T01-2', 'S012X1191', 'in'),
(1, 'VHS', 'T01-3', 'S013X5890', 'in'),
(2, 'DVD', 'T02-1', 'S021X7547', 'in'),
(2, 'BLURAY', 'T02-2', 'S022X7289', 'in'),
(2, 'VHS', 'T02-3', 'S023X2528', 'in'),
(3, 'DVD', 'T03-1', 'S031X2188', 'in'),
(3, 'BLURAY', 'T03-2', 'S032X2476', 'in'),
(3, 'VHS', 'T03-3', 'S033X6124', 'out'),
(4, 'DVD', 'T04-1', 'S041X4717', 'out'),
(4, 'BLURAY', 'T04-2', 'S042X7992', 'in'),
(4, 'VHS', 'T04-3', 'S043X1955', 'in'),
(5, 'DVD', 'T05-1', 'S051X3675', 'in'),
(5, 'BLURAY', 'T05-2', 'S052X9347', 'in'),
(5, 'VHS', 'T05-3', 'S053X2358', 'in'),
(6, 'DVD', 'T06-1', 'S061X5988', 'in'),
(6, 'BLURAY', 'T06-2', 'S062X9188', 'in'),
(6, 'VHS', 'T06-3', 'S063X8960', 'out'),
(7, 'DVD', 'T07-1', 'S071X3763', 'in'),
(7, 'BLURAY', 'T07-2', 'S072X4792', 'out'),
(7, 'VHS', 'T07-3', 'S073X5038', 'in'),
(8, 'DVD', 'T08-1', 'S081X1442', 'out'),
(8, 'BLURAY', 'T08-2', 'S082X5993', 'out'),
(8, 'VHS', 'T08-3', 'S083X8800', 'in'),
(9, 'DVD', 'T09-1', 'S091X8045', 'in'),
(9, 'BLURAY', 'T09-2', 'S092X2095', 'out'),
(9, 'VHS', 'T09-3', 'S093X5942', 'out'),
(10, 'DVD', 'T10-1', 'S101X4074', 'in'),
(10, 'BLURAY', 'T10-2', 'S102X2259', 'out'),
(10, 'VHS', 'T10-3', 'S103X7576', 'in'),
(11, 'DVD', 'T11-1', 'S111X7292', 'in'),
(11, 'BLURAY', 'T11-2', 'S112X6562', 'out'),
(11, 'VHS', 'T11-3', 'S113X9394', 'in'),
(12, 'DVD', 'T12-1', 'S121X4147', 'out'),
(12, 'BLURAY', 'T12-2', 'S122X3578', 'in'),
(12, 'VHS', 'T12-3', 'S123X1256', 'in'),
(13, 'DVD', 'T13-1', 'S131X4523', 'out'),
(13, 'BLURAY', 'T13-2', 'S132X6468', 'in'),
(13, 'VHS', 'T13-3', 'S133X7963', 'in'),
(14, 'DVD', 'T14-1', 'S141X4676', 'in'),
(14, 'BLURAY', 'T14-2', 'S142X5174', 'in'),
(14, 'VHS', 'T14-3', 'S143X8536', 'in'),
(15, 'DVD', 'T15-1', 'S151X8995', 'in'),
(15, 'BLURAY', 'T15-2', 'S152X6727', 'in'),
(15, 'VHS', 'T15-3', 'S153X4612', 'in'),
(16, 'DVD', 'T16-1', 'S161X1406', 'in'),
(16, 'BLURAY', 'T16-2', 'S162X4400', 'out'),
(16, 'VHS', 'T16-3', 'S163X1290', 'in'),
(17, 'DVD', 'T17-1', 'S171X3791', 'in'),
(17, 'BLURAY', 'T17-2', 'S172X7944', 'out'),
(17, 'VHS', 'T17-3', 'S173X6818', 'in'),
(18, 'DVD', 'T18-1', 'S181X6024', 'out'),
(18, 'BLURAY', 'T18-2', 'S182X3089', 'out'),
(18, 'VHS', 'T18-3', 'S183X1703', 'in'),
(19, 'DVD', 'T19-1', 'S191X1215', 'in'),
(19, 'BLURAY', 'T19-2', 'S192X7365', 'in'),
(19, 'VHS', 'T19-3', 'S193X6463', 'in'),
(20, 'DVD', 'T20-1', 'S201X5947', 'in'),
(20, 'BLURAY', 'T20-2', 'S202X8110', 'in'),
(20, 'VHS', 'T20-3', 'S203X4509', 'in');

INSERT INTO movie_distributor (movie_id, distributor_id, format, wholesale_price, catalog_price_code) VALUES
(1, 7, 'VHS', 13.63, 'P0107V'),
(1, 6, 'DVD', 20.71, 'P0106D'),
(1, 4, 'BLURAY', 12.04, 'P0104B'),
(2, 3, 'DVD', 13.34, 'P0203D'),
(2, 9, 'BLURAY', 15.29, 'P0209B'),
(2, 1, 'VHS', 8.95, 'P0201V'),
(3, 2, 'BLURAY', 14.64, 'P0302B'),
(3, 10, 'VHS', 14.22, 'P0310V'),
(3, 4, 'DVD', 11.20, 'P0304D'),
(4, 16, 'VHS', 16.43, 'P0416V'),
(4, 5, 'DVD', 11.99, 'P0405D'),
(4, 10, 'BLURAY', 12.18, 'P0410B'),
(5, 4, 'DVD', 19.95, 'P0504D'),
(5, 10, 'BLURAY', 15.03, 'P0510B'),
(5, 2, 'VHS', 14.14, 'P0502V'),
(6, 13, 'BLURAY', 17.54, 'P0613B'),
(6, 8, 'VHS', 10.04, 'P0608V'),
(6, 1, 'DVD', 19.22, 'P0601D'),
(7, 1, 'VHS', 18.94, 'P0701V'),
(7, 2, 'DVD', 15.93, 'P0702D'),
(7, 7, 'BLURAY', 17.73, 'P0707B'),
(8, 7, 'DVD', 8.15, 'P0807D'),
(8, 4, 'BLURAY', 15.44, 'P0804B'),
(8, 11, 'VHS', 14.05, 'P0811V'),
(9, 9, 'BLURAY', 21.72, 'P0909B'),
(9, 3, 'VHS', 17.88, 'P0903V'),
(9, 8, 'DVD', 12.99, 'P0908D'),
(10, 3, 'VHS', 21.20, 'P1003V'),
(10, 12, 'DVD', 13.50, 'P1012D'),
(10, 5, 'BLURAY', 12.34, 'P1005B'),
(11, 1, 'DVD', 9.68, 'P1101D'),
(11, 2, 'BLURAY', 12.02, 'P1102B'),
(11, 18, 'VHS', 17.15, 'P1118V'),
(12, 8, 'BLURAY', 19.30, 'P1208B'),
(12, 2, 'VHS', 19.89, 'P1202V'),
(12, 13, 'DVD', 16.56, 'P1213D'),
(13, 17, 'VHS', 21.66, 'P1317V'),
(13, 5, 'DVD', 17.54, 'P1305D'),
(13, 6, 'BLURAY', 21.51, 'P1306B'),
(14, 13, 'DVD', 19.12, 'P1413D'),
(14, 10, 'BLURAY', 14.94, 'P1410B'),
(14, 7, 'VHS', 10.78, 'P1407V'),
(15, 19, 'BLURAY', 11.75, 'P1519B'),
(15, 17, 'VHS', 19.58, 'P1517V'),
(15, 8, 'DVD', 16.35, 'P1508D'),
(16, 7, 'VHS', 11.25, 'P1607V'),
(16, 11, 'DVD', 18.84, 'P1611D'),
(16, 14, 'BLURAY', 18.36, 'P1614B'),
(17, 8, 'DVD', 14.46, 'P1708D'),
(17, 19, 'BLURAY', 11.68, 'P1719B'),
(17, 12, 'VHS', 13.73, 'P1712V'),
(18, 12, 'BLURAY', 19.89, 'P1812B'),
(18, 18, 'VHS', 14.47, 'P1818V'),
(18, 4, 'DVD', 17.37, 'P1804D'),
(19, 15, 'VHS', 16.28, 'P1915V'),
(19, 18, 'DVD', 14.37, 'P1918D'),
(19, 13, 'BLURAY', 9.47, 'P1913B'),
(20, 2, 'DVD', 19.79, 'P2002D'),
(20, 18, 'BLURAY', 19.63, 'P2018B'),
(20, 10, 'VHS', 20.58, 'P2010V');

INSERT INTO rental (customer_id, copy_id, rental_date, due_date, return_date) VALUES
(4, 26, DATE '2026-02-13', DATE '2026-02-16', DATE '2026-02-17'),
(9, 18, DATE '2025-12-16', DATE '2025-12-19', NULL),
(15, 27, DATE '2025-11-01', DATE '2025-11-04', DATE '2025-11-04'),
(9, 35, DATE '2025-10-24', DATE '2025-10-27', DATE '2025-10-27'),
(11, 38, DATE '2025-12-01', DATE '2025-12-04', DATE '2025-12-06'),
(14, 59, DATE '2025-12-18', DATE '2025-12-21', DATE '2025-12-22'),
(6, 21, DATE '2026-01-04', DATE '2026-01-07', NULL),
(18, 29, DATE '2025-12-09', DATE '2025-12-12', DATE '2025-12-12'),
(17, 31, DATE '2025-10-20', DATE '2025-10-23', DATE '2025-10-23'),
(3, 3, DATE '2025-10-02', DATE '2025-10-05', DATE '2025-10-10'),
(1, 10, DATE '2025-11-06', DATE '2025-11-09', DATE '2025-11-14'),
(18, 3, DATE '2026-02-13', DATE '2026-02-16', DATE '2026-02-18'),
(1, 12, DATE '2026-01-07', DATE '2026-01-10', DATE '2026-01-12'),
(6, 49, DATE '2026-01-23', DATE '2026-01-26', NULL),
(15, 9, DATE '2025-10-15', DATE '2025-10-18', DATE '2025-10-23'),
(5, 47, DATE '2025-12-07', DATE '2025-12-10', DATE '2025-12-12'),
(20, 9, DATE '2026-01-29', DATE '2026-02-01', DATE '2026-02-06'),
(13, 54, DATE '2025-11-22', DATE '2025-11-25', DATE '2025-11-25'),
(9, 38, DATE '2026-01-29', DATE '2026-02-01', DATE '2026-02-03'),
(13, 27, DATE '2025-12-12', DATE '2025-12-15', NULL);

INSERT INTO charge (rental_id, charge_type, amount, tax_amount, charge_date) VALUES
(1, 'base', 5.98, 0.48, DATE '2026-02-13'),
(1, 'late', 1.50, 0.12, DATE '2026-02-17'),
(2, 'base', 5.04, 0.40, DATE '2025-12-16'),
(2, 'damage', 8.48, 0.68, DATE '2025-12-19'),
(3, 'base', 4.58, 0.37, DATE '2025-11-01'),
(4, 'base', 5.93, 0.47, DATE '2025-10-24'),
(5, 'base', 2.99, 0.24, DATE '2025-12-01'),
(5, 'late', 3.00, 0.24, DATE '2025-12-06'),
(6, 'base', 3.53, 0.28, DATE '2025-12-18'),
(6, 'late', 1.50, 0.12, DATE '2025-12-22'),
(7, 'base', 5.60, 0.45, DATE '2026-01-04'),
(8, 'base', 5.81, 0.46, DATE '2025-12-09'),
(9, 'base', 4.03, 0.32, DATE '2025-10-20'),
(9, 'damage', 9.01, 0.72, DATE '2025-10-23'),
(10, 'base', 4.44, 0.36, DATE '2025-10-02'),
(10, 'late', 7.50, 0.60, DATE '2025-10-10'),
(11, 'base', 5.86, 0.47, DATE '2025-11-06'),
(11, 'late', 7.50, 0.60, DATE '2025-11-14'),
(12, 'base', 3.24, 0.26, DATE '2026-02-13'),
(12, 'late', 3.00, 0.24, DATE '2026-02-18'),
(12, 'damage', 10.26, 0.82, DATE '2026-02-18'),
(13, 'base', 3.11, 0.25, DATE '2026-01-07'),
(13, 'late', 3.00, 0.24, DATE '2026-01-12'),
(13, 'damage', 4.74, 0.38, DATE '2026-01-12'),
(14, 'base', 3.40, 0.27, DATE '2026-01-23'),
(15, 'base', 5.44, 0.44, DATE '2025-10-15'),
(15, 'late', 7.50, 0.60, DATE '2025-10-23'),
(15, 'damage', 3.90, 0.31, DATE '2025-10-23'),
(16, 'base', 3.36, 0.27, DATE '2025-12-07'),
(16, 'late', 3.00, 0.24, DATE '2025-12-12'),
(17, 'base', 5.17, 0.41, DATE '2026-01-29'),
(17, 'late', 7.50, 0.60, DATE '2026-02-06'),
(17, 'damage', 13.62, 1.09, DATE '2026-02-06'),
(18, 'base', 4.18, 0.33, DATE '2025-11-22'),
(19, 'base', 3.20, 0.26, DATE '2026-01-29'),
(19, 'late', 3.00, 0.24, DATE '2026-02-03'),
(19, 'damage', 7.05, 0.56, DATE '2026-02-03'),
(20, 'base', 3.95, 0.32, DATE '2025-12-12');

INSERT INTO discount (scope, movie_id, genre_id, start_date, end_date, discount_pct) VALUES
('genre', NULL, 4, DATE '2025-11-03', DATE '2025-12-25', 22.18),
('movie', 10, NULL, DATE '2025-05-11', DATE '2025-06-17', 13.83),
('genre', NULL, 2, DATE '2025-02-04', DATE '2025-03-30', 6.35),
('movie', 4, NULL, DATE '2025-03-13', DATE '2025-05-10', 20.48),
('genre', NULL, 7, DATE '2025-06-23', DATE '2025-07-17', 30.46),
('movie', 18, NULL, DATE '2025-07-19', DATE '2025-08-13', 18.15),
('genre', NULL, 16, DATE '2025-01-12', DATE '2025-02-19', 13.54),
('movie', 1, NULL, DATE '2025-09-24', DATE '2025-10-12', 15.59),
('genre', NULL, 11, DATE '2025-03-07', DATE '2025-04-05', 11.09),
('movie', 3, NULL, DATE '2025-11-24', DATE '2026-01-16', 25.75),
('genre', NULL, 12, DATE '2026-01-03', DATE '2026-01-24', 11.38),
('movie', 15, NULL, DATE '2025-07-29', DATE '2025-08-19', 27.05),
('genre', NULL, 12, DATE '2025-02-25', DATE '2025-03-27', 19.49),
('movie', 14, NULL, DATE '2025-08-08', DATE '2025-10-04', 16.74),
('genre', NULL, 15, DATE '2025-09-20', DATE '2025-10-25', 11.38),
('movie', 3, NULL, DATE '2025-02-23', DATE '2025-03-15', 26.27),
('genre', NULL, 9, DATE '2025-03-05', DATE '2025-05-03', 7.18),
('movie', 1, NULL, DATE '2025-10-27', DATE '2025-12-25', 32.15),
('genre', NULL, 15, DATE '2025-11-09', DATE '2025-11-28', 31.23),
('movie', 20, NULL, DATE '2025-03-23', DATE '2025-04-11', 18.99);

INSERT INTO person (full_name, person_type) VALUES
('Person 01', 'writer'),
('Person 02', 'director'),
('Person 03', 'actress'),
('Person 04', 'actress'),
('Person 05', 'director'),
('Person 06', 'writer'),
('Person 07', 'producer'),
('Person 08', 'actress'),
('Person 09', 'writer'),
('Person 10', 'actress'),
('Person 11', 'producer'),
('Person 12', 'writer'),
('Person 13', 'producer'),
('Person 14', 'actor'),
('Person 15', 'actor'),
('Person 16', 'actress'),
('Person 17', 'director'),
('Person 18', 'actress'),
('Person 19', 'producer'),
('Person 20', 'writer'),
('Person 21', 'writer'),
('Person 22', 'writer'),
('Person 23', 'producer'),
('Person 24', 'actor'),
('Person 25', 'actress'),
('Person 26', 'writer'),
('Person 27', 'writer'),
('Person 28', 'director'),
('Person 29', 'actor'),
('Person 30', 'actor'),
('Person 31', 'writer'),
('Person 32', 'actor'),
('Person 33', 'director'),
('Person 34', 'director'),
('Person 35', 'writer'),
('Person 36', 'writer'),
('Person 37', 'actor'),
('Person 38', 'actor'),
('Person 39', 'producer'),
('Person 40', 'actress');

INSERT INTO movie_person (movie_id, person_id, role) VALUES
(1, 7, 'Director'),
(1, 17, 'Actor'),
(1, 16, 'Actor'),
(2, 21, 'Producer'),
(2, 2, 'Producer'),
(2, 22, 'Director'),
(3, 26, 'Director'),
(3, 10, 'Actress'),
(3, 15, 'Producer'),
(4, 27, 'Writer'),
(4, 11, 'Producer'),
(4, 38, 'Actor'),
(5, 16, 'Actress'),
(5, 38, 'Actress'),
(5, 35, 'Producer'),
(6, 9, 'Producer'),
(6, 8, 'Writer'),
(6, 20, 'Actor'),
(7, 17, 'Director'),
(7, 19, 'Director'),
(7, 25, 'Actress'),
(8, 20, 'Actress'),
(8, 22, 'Actor'),
(8, 14, 'Actor'),
(9, 38, 'Actress'),
(9, 3, 'Actress'),
(9, 24, 'Producer'),
(10, 22, 'Actress'),
(10, 34, 'Actress'),
(10, 11, 'Director'),
(11, 8, 'Producer'),
(11, 5, 'Actress'),
(11, 15, 'Writer'),
(12, 26, 'Director'),
(12, 11, 'Writer'),
(12, 17, 'Writer'),
(13, 2, 'Director'),
(13, 6, 'Director'),
(13, 15, 'Director'),
(14, 13, 'Director'),
(14, 30, 'Director'),
(14, 8, 'Director'),
(15, 28, 'Writer'),
(15, 5, 'Producer'),
(15, 10, 'Producer'),
(16, 25, 'Actress'),
(16, 21, 'Actor'),
(16, 13, 'Actor'),
(17, 29, 'Actress'),
(17, 5, 'Producer'),
(17, 7, 'Producer'),
(18, 11, 'Writer'),
(18, 20, 'Actress'),
(18, 19, 'Writer'),
(19, 32, 'Actress'),
(19, 13, 'Director'),
(19, 5, 'Actress'),
(20, 24, 'Actor'),
(20, 10, 'Director'),
(20, 4, 'Writer');

INSERT INTO oscar (oscar_year, category, result, movie_id, person_id) VALUES
(2015, 'Best Director', 'nominated', NULL, 37),
(2025, 'Best Actor', 'won', 20, NULL),
(2006, 'Best Picture', 'won', NULL, 26),
(2009, 'Best Original Screenplay', 'won', 7, NULL),
(2008, 'Best Actor', 'nominated', NULL, 15),
(2014, 'Best Actress', 'nominated', 9, NULL),
(2013, 'Best Actor', 'won', NULL, 10),
(2022, 'Best Original Screenplay', 'nominated', 13, NULL),
(2020, 'Best Original Screenplay', 'nominated', NULL, 37),
(2018, 'Best Original Screenplay', 'won', 11, NULL),
(2000, 'Best Director', 'won', NULL, 5),
(2014, 'Best Original Screenplay', 'won', 5, NULL),
(2003, 'Best Picture', 'nominated', NULL, 35),
(2023, 'Best Original Screenplay', 'won', 4, NULL),
(2024, 'Best Actress', 'nominated', NULL, 17),
(2023, 'Best Original Screenplay', 'won', 17, NULL),
(2002, 'Best Original Screenplay', 'won', NULL, 33),
(2004, 'Best Actress', 'won', 19, NULL),
(2000, 'Best Actress', 'won', NULL, 9),
(2017, 'Best Original Screenplay', 'nominated', 10, NULL);

COMMIT;
SELECT 'genre' AS table_name, COUNT(*) FROM genre
UNION ALL SELECT 'movie', COUNT(*) FROM movie
UNION ALL SELECT 'distributor', COUNT(*) FROM distributor
UNION ALL SELECT 'customer', COUNT(*) FROM customer
UNION ALL SELECT 'copy', COUNT(*) FROM copy
UNION ALL SELECT 'movie_distributor', COUNT(*) FROM movie_distributor
UNION ALL SELECT 'rental', COUNT(*) FROM rental
UNION ALL SELECT 'charge', COUNT(*) FROM charge
UNION ALL SELECT 'discount', COUNT(*) FROM discount
UNION ALL SELECT 'person', COUNT(*) FROM person
UNION ALL SELECT 'movie_person', COUNT(*) FROM movie_person
UNION ALL SELECT 'oscar', COUNT(*) FROM oscar;