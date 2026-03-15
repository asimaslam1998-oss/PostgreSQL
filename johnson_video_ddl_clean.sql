-- Johnson Video Store - DDL (PostgreSQL)

-- SQL used for CREATE TABLE + INSERT (seeding)
-- Johnson Video Store database schema (PostgreSQL)

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
  genre_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE movie (
  movie_id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  rating VARCHAR(10),
  year_released INT CHECK (year_released >= 1888 AND year_released <= EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1),
  runtime_min INT CHECK (runtime_min IS NULL OR runtime_min > 0),
  genre_id INT REFERENCES genre(genre_id),
  catalog_movie_code VARCHAR(40) UNIQUE
);

CREATE TABLE distributor (
  distributor_id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL UNIQUE,
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
  store_tag_no VARCHAR(30) NOT NULL UNIQUE,
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
  CONSTRAINT due_after_rental CHECK (due_date >= rental_date),
  CONSTRAINT return_after_rental CHECK (return_date IS NULL OR return_date >= rental_date)
);

CREATE TABLE charge (
  charge_id SERIAL PRIMARY KEY,
  rental_id INT NOT NULL REFERENCES rental(rental_id) ON DELETE CASCADE,
  charge_type VARCHAR(20) NOT NULL CHECK (charge_type IN ('base','late','damage','rewind','tax')),
  amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  tax_amount NUMERIC(10,2) NOT NULL CHECK (tax_amount >= 0),
  charge_date DATE NOT NULL
);

CREATE TABLE discount (
  discount_id SERIAL PRIMARY KEY,
  scope VARCHAR(10) NOT NULL CHECK (scope IN ('movie','genre')),
  movie_id INT REFERENCES movie(movie_id),
  genre_id INT REFERENCES genre(genre_id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  discount_pct NUMERIC(5,2) NOT NULL CHECK (discount_pct >= 0 AND discount_pct <= 100),
  CONSTRAINT discount_scope_ck CHECK (
    (scope='movie' AND movie_id IS NOT NULL AND genre_id IS NULL)
    OR
    (scope='genre' AND genre_id IS NOT NULL AND movie_id IS NULL)
  ),
  CONSTRAINT discount_dates_ck CHECK (end_date >= start_date)
);

CREATE TABLE person (
  person_id SERIAL PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL UNIQUE,
  person_type VARCHAR(20) NOT NULL CHECK (person_type IN ('actor','director','writer','producer'))
);

CREATE TABLE movie_person (
  movie_id INT NOT NULL REFERENCES movie(movie_id) ON DELETE CASCADE,
  person_id INT NOT NULL REFERENCES person(person_id) ON DELETE CASCADE,
  role VARCHAR(30) NOT NULL,
  PRIMARY KEY (movie_id, person_id, role)
);

CREATE TABLE oscar (
  oscar_id SERIAL PRIMARY KEY,
  oscar_year INT NOT NULL CHECK (oscar_year >= 1929 AND oscar_year <= EXTRACT(YEAR FROM CURRENT_DATE)::INT + 1),
  category VARCHAR(80) NOT NULL,
  result VARCHAR(10) NOT NULL CHECK (result IN ('won','nominated')),
  movie_id INT REFERENCES movie(movie_id),
  person_id INT REFERENCES person(person_id),
  CONSTRAINT oscar_target_ck CHECK (
    (movie_id IS NOT NULL AND person_id IS NULL) OR (person_id IS NOT NULL AND movie_id IS NULL)
  )
);

COMMIT;

-- Seed data (20 rows per table minimum)
BEGIN;

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

('City Shadows','NR',2012,111,3,'CAT-0001'),
('Neon Horizon','R',2001,131,19,'CAT-0002'),
('River of Stars','PG-13',1994,138,14,'CAT-0003'),
('Midnight Circuit','PG-13',2001,126,16,'CAT-0004'),
('Golden Hour','PG',2022,87,10,'CAT-0005'),
('Silent Harbor','R',2007,158,19,'CAT-0006'),
('Echo Valley','NR',2012,157,10,'CAT-0007'),
('Crimson Skyline','R',2023,120,1,'CAT-0008'),
('Paper Kingdom','G',2019,86,6,'CAT-0009'),
('The Last Lantern','PG-13',1999,100,1,'CAT-0010'),
('Blue Meridian','PG',2009,95,1,'CAT-0011'),
('Winter Frequency','NR',2013,123,15,'CAT-0012'),
('Copper Moon','G',2004,145,8,'CAT-0013'),
('Signal & Noise','NR',2002,80,11,'CAT-0014'),
('Glass River','G',2020,170,19,'CAT-0015'),
('Orbit of Dreams','R',1990,141,10,'CAT-0016'),
('Second Sunrise','NR',2003,110,8,'CAT-0017'),
('Parallel Street','PG-13',2002,162,3,'CAT-0018'),
('Sunset Archive','PG-13',2001,128,7,'CAT-0019'),
('Northbound','PG-13',2006,158,9,'CAT-0020');

('Distributor 01','(996) 519-3102','distributor01@dist.example.com','817 Market St'),
('Distributor 02','(260) 635-6920','distributor02@dist.example.com','807 Market St'),
('Distributor 03','(211) 575-1035','distributor03@dist.example.com','438 Market St'),
('Distributor 04','(217) 217-5422','distributor04@dist.example.com','951 Market St'),
('Distributor 05','(548) 479-8289','distributor05@dist.example.com','518 Market St'),
('Distributor 06','(810) 579-6379','distributor06@dist.example.com','135 Market St'),
('Distributor 07','(593) 540-1295','distributor07@dist.example.com','844 Market St'),
('Distributor 08','(713) 360-6549','distributor08@dist.example.com','844 Market St'),
('Distributor 09','(599) 804-6401','distributor09@dist.example.com','74 Market St'),
('Distributor 10','(382) 779-7436','distributor10@dist.example.com','399 Market St'),
('Distributor 11','(314) 712-1370','distributor11@dist.example.com','649 Market St'),
('Distributor 12','(641) 696-8185','distributor12@dist.example.com','254 Market St'),
('Distributor 13','(658) 424-4942','distributor13@dist.example.com','968 Market St'),
('Distributor 14','(376) 880-9486','distributor14@dist.example.com','650 Market St'),
('Distributor 15','(806) 444-9120','distributor15@dist.example.com','279 Market St'),
('Distributor 16','(452) 745-8085','distributor16@dist.example.com','598 Market St'),
('Distributor 17','(994) 739-7527','distributor17@dist.example.com','144 Market St'),
('Distributor 18','(411) 524-2569','distributor18@dist.example.com','366 Market St'),
('Distributor 19','(456) 573-8356','distributor19@dist.example.com','24 Market St'),
('Distributor 20','(447) 889-9733','distributor20@dist.example.com','923 Market St');

('Alex','Smith','4968 Elm Ave','(602) 349-1144','alexsmith1@customer.example.com'),
('Jordan','Johnson','3913 Elm Ave','(508) 788-2922','jordanjohnson2@customer.example.com'),
('Taylor','Williams','6111 Elm Ave','(255) 709-7633','taylorwilliams3@customer.example.com'),
('Casey','Brown','7197 Elm Ave','(580) 350-2660','caseybrown4@customer.example.com'),
('Riley','Jones','9079 Elm Ave','(743) 653-1197','rileyjones5@customer.example.com'),
('Morgan','Miller','5665 Elm Ave','(849) 447-6051','morganmiller6@customer.example.com'),
('Jamie','Davis','722 Elm Ave','(985) 618-2055','jamiedavis7@customer.example.com'),
('Avery','Garcia','6562 Elm Ave','(462) 704-9742','averygarcia8@customer.example.com'),
('Parker','Rodriguez','1905 Elm Ave','(468) 366-7944','parkerrodriguez9@customer.example.com'),
('Quinn','Wilson','9900 Elm Ave','(496) 859-6943','quinnwilson10@customer.example.com'),
('Reese','Martinez','6709 Elm Ave','(444) 992-5221','reesemartinez11@customer.example.com'),
('Drew','Anderson','873 Elm Ave','(838) 722-6858','drewanderson12@customer.example.com'),
('Skyler','Taylor','1433 Elm Ave','(881) 822-9908','skylertaylor13@customer.example.com'),
('Kendall','Thomas','3983 Elm Ave','(421) 683-3469','kendallthomas14@customer.example.com'),
('Rowan','Hernandez','5366 Elm Ave','(304) 252-9559','rowanhernandez15@customer.example.com'),
('Cameron','Moore','2189 Elm Ave','(975) 274-8228','cameronmoore16@customer.example.com'),
('Finley','Martin','3686 Elm Ave','(576) 418-7747','finleymartin17@customer.example.com'),
('Hayden','Jackson','7158 Elm Ave','(714) 490-3512','haydenjackson18@customer.example.com'),
('Logan','Thompson','7935 Elm Ave','(700) 778-9358','loganthompson19@customer.example.com'),
('Dakota','Lee','8070 Elm Ave','(896) 867-2298','dakotalee20@customer.example.com');

(1,'VHS','TAG-00001','SER-401458','in'),
(2,'DVD','TAG-00002','SER-568854','in'),
(3,'VHS','TAG-00003','SER-538471','in'),
(4,'VHS','TAG-00004','SER-622518','in'),
(5,'DVD','TAG-00005','SER-549728','in'),
(6,'BLURAY','TAG-00006','SER-811730','in'),
(7,'VHS','TAG-00007','SER-590054','in'),
(8,'DVD','TAG-00008','SER-595258','in'),
(9,'DVD','TAG-00009','SER-928152','in'),
(10,'VHS','TAG-00010','SER-813638','in'),
(11,'DVD','TAG-00011','SER-461503','in'),
(12,'BLURAY','TAG-00012','SER-896083','in'),
(13,'BLURAY','TAG-00013','SER-385154','in'),
(14,'DVD','TAG-00014','SER-672124','in'),
(15,'VHS','TAG-00015','SER-346912','in'),
(16,'DVD','TAG-00016','SER-220387','in'),
(17,'VHS','TAG-00017','SER-830824','in'),
(18,'BLURAY','TAG-00018','SER-450379','in'),
(19,'VHS','TAG-00019','SER-465468','in'),
(20,'BLURAY','TAG-00020','SER-160164','in');

(1,1,'BLURAY',16.13,'P001-001-B'),
(2,2,'BLURAY',5.92,'P002-002-B'),
(3,3,'BLURAY',6.86,'P003-003-B'),
(4,4,'VHS',24.13,'P004-004-V'),
(5,5,'BLURAY',16.27,'P005-005-B'),
(6,6,'VHS',10.87,'P006-006-V'),
(7,7,'BLURAY',11.41,'P007-007-B'),
(8,8,'BLURAY',8.23,'P008-008-B'),
(9,9,'BLURAY',11.0,'P009-009-B'),
(10,10,'BLURAY',12.71,'P010-010-B'),
(11,11,'BLURAY',7.69,'P011-011-B'),
(12,12,'BLURAY',6.54,'P012-012-B'),
(13,13,'BLURAY',20.4,'P013-013-B'),
(14,14,'BLURAY',10.47,'P014-014-B'),
(15,15,'DVD',5.92,'P015-015-D'),
(16,16,'DVD',9.44,'P016-016-D'),
(17,17,'BLURAY',23.7,'P017-017-B'),
(18,18,'VHS',8.96,'P018-018-V'),
(19,19,'DVD',20.41,'P019-019-D'),
(20,20,'BLURAY',23.89,'P020-020-B');

(1,1,'2026-01-11','2026-01-14',NULL),
(2,2,'2026-01-12','2026-01-15','2026-01-16'),
(3,3,'2026-01-13','2026-01-16',NULL),
(4,4,'2026-01-14','2026-01-17','2026-01-18'),
(5,5,'2026-01-15','2026-01-18',NULL),
(6,6,'2026-01-16','2026-01-19','2026-01-19'),
(7,7,'2026-01-17','2026-01-20',NULL),
(8,8,'2026-01-18','2026-01-21','2026-01-21'),
(9,9,'2026-01-19','2026-01-22',NULL),
(10,10,'2026-01-20','2026-01-23','2026-01-24'),
(11,11,'2026-01-21','2026-01-24',NULL),
(12,12,'2026-01-22','2026-01-25','2026-01-28'),
(13,13,'2026-01-23','2026-01-26',NULL),
(14,14,'2026-01-24','2026-01-27','2026-01-30'),
(15,15,'2026-01-25','2026-01-28',NULL),
(16,16,'2026-01-26','2026-01-29','2026-01-29'),
(17,17,'2026-01-27','2026-01-30',NULL),
(18,18,'2026-01-28','2026-01-31','2026-02-01'),
(19,19,'2026-01-29','2026-02-01',NULL),
(20,20,'2026-01-30','2026-02-02','2026-02-05');

(1,'base',3.7,0.26,'2026-01-11'),
(2,'damage',5.03,0.35,'2026-01-12'),
(3,'rewind',5.62,0.39,'2026-01-13'),
(4,'damage',7.12,0.5,'2026-01-14'),
(5,'rewind',6.76,0.47,'2026-01-15'),
(6,'late',3.61,0.25,'2026-01-16'),
(7,'base',3.41,0.24,'2026-01-17'),
(8,'base',7.15,0.5,'2026-01-18'),
(9,'rewind',3.88,0.27,'2026-01-19'),
(10,'late',2.72,0.19,'2026-01-20'),
(11,'late',8.55,0.6,'2026-01-21'),
(12,'tax',8.03,0.56,'2026-01-22'),
(13,'rewind',3.14,0.22,'2026-01-23'),
(14,'damage',5.87,0.41,'2026-01-24'),
(15,'tax',2.22,0.16,'2026-01-25'),
(16,'damage',8.69,0.61,'2026-01-26'),
(17,'late',7.24,0.51,'2026-01-27'),
(18,'damage',1.72,0.12,'2026-01-28'),
(19,'rewind',2.98,0.21,'2026-01-29'),
(20,'rewind',2.23,0.16,'2026-01-30');

('movie',1,NULL,'2026-02-02','2026-02-16',18.62),
('genre',NULL,2,'2026-02-03','2026-02-17',12.37),
('movie',3,NULL,'2026-02-04','2026-02-18',8.11),
('genre',NULL,4,'2026-02-05','2026-02-19',18.65),
('movie',5,NULL,'2026-02-06','2026-02-20',6.62),
('genre',NULL,6,'2026-02-07','2026-02-21',10.9),
('movie',7,NULL,'2026-02-08','2026-02-22',6.17),
('genre',NULL,8,'2026-02-09','2026-02-23',16.83),
('movie',9,NULL,'2026-02-10','2026-02-24',20.88),
('genre',NULL,10,'2026-02-11','2026-02-25',22.42),
('movie',11,NULL,'2026-02-12','2026-02-26',6.77),
('genre',NULL,12,'2026-02-13','2026-02-27',9.58),
('movie',13,NULL,'2026-02-14','2026-02-28',21.38),
('genre',NULL,14,'2026-02-15','2026-03-01',7.66),
('movie',15,NULL,'2026-02-16','2026-03-02',5.45),
('genre',NULL,16,'2026-02-17','2026-03-03',22.02),
('movie',17,NULL,'2026-02-18','2026-03-04',16.49),
('genre',NULL,18,'2026-02-19','2026-03-05',17.05),
('movie',19,NULL,'2026-02-20','2026-03-06',5.45),
('genre',NULL,20,'2026-02-21','2026-03-07',12.22);

('Ava Patel','director'),
('Noah Kim','director'),
('Liam Johnson','actor'),
('Emma Garcia','actor'),
('Olivia Chen','producer'),
('Mason Davis','actor'),
('Sophia Brown','producer'),
('Ethan Martinez','producer'),
('Mia Wilson','producer'),
('Lucas Anderson','director'),
('Isabella Thomas','producer'),
('James Taylor','producer'),
('Amelia Moore','producer'),
('Benjamin Jackson','actor'),
('Harper White','writer'),
('Henry Harris','actor'),
('Evelyn Martin','actor'),
('Daniel Thompson','actor'),
('Charlotte Lee','writer'),
('Michael Clark','director');

(1,1,'Director'),
(2,2,'Writer'),
(3,3,'Writer'),
(4,4,'Director'),
(5,5,'Actor'),
(6,6,'Writer'),
(7,7,'Actor'),
(8,8,'Actor'),
(9,9,'Actor'),
(10,10,'Director'),
(11,11,'Actor'),
(12,12,'Writer'),
(13,13,'Writer'),
(14,14,'Writer'),
(15,15,'Writer'),
(16,16,'Actor'),
(17,17,'Director'),
(18,18,'Director'),
(19,19,'Writer'),
(20,20,'Actor');

(2010,'Best Actor','nominated',1,NULL),
(2019,'Best Original Screenplay','won',NULL,2),
(2012,'Best Actor','won',3,NULL),
(2014,'Best Picture','won',NULL,4),
(2020,'Best Original Screenplay','won',5,NULL),
(2005,'Best Director','won',NULL,6),
(2013,'Best Original Screenplay','won',7,NULL),
(2015,'Best Director','won',NULL,8),
(2008,'Best Actress','nominated',9,NULL),
(2010,'Best Original Screenplay','won',NULL,10),
(2003,'Best Original Screenplay','nominated',11,NULL),
(2025,'Best Actor','nominated',NULL,12),
(2013,'Best Actor','nominated',13,NULL),
(2008,'Best Original Screenplay','nominated',NULL,14),
(2012,'Best Actor','nominated',15,NULL),
(2012,'Best Picture','nominated',NULL,16),
(2011,'Best Picture','nominated',17,NULL),
(2017,'Best Director','won',NULL,18),
(2014,'Best Picture','won',19,NULL),
(2003,'Best Actor','nominated',NULL,20);

COMMIT;