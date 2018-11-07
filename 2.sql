#1
create database if not exists `Laboratorium-Filmoteka`;
create user '244750'@'localhost' identified by 'piotr750';
GRANT SELECT, INSERT, UPDATE ON `Laboratorium-Filmoteka`.* TO '244750'@'localhost';
show tables;

#2
USE `Laboratorium-Filmoteka`;
CREATE TABLE aktorzy (
	ID int NOT NULL,
	Imię varchar(32),
    Nazwisko varchar(32),
    primary key (ID)
);

CREATE TABLE filmy (
	ID int NOT NULL,
    Tytuł varchar(64),
    Gatunek varchar(32),
    Długość int,
    primary key (ID)
);

CREATE TABLE zagrali (
	Film int,
    Aktor int,
    FOREIGN KEY (Film) REFERENCES filmy(ID),
    FOREIGN KEY (Aktor) REFERENCES aktorzy(ID)
);

INSERT INTO aktorzy (ID, Imię, Nazwisko)
	SELECT actor_id, first_name, last_name
    FROM sakila.actor
    WHERE first_name NOT LIKE "%x%" AND first_name NOT LIKE "%v%" AND first_name NOT LIKE "%q%"
		AND last_name NOT LIKE "%x%" AND last_name NOT LIKE "%v%" AND last_name NOT LIKE "%q%";

INSERT INTO filmy (ID, Tytuł, Gatunek, Długość)
	SELECT film.film_id, title, category.name ,length
    FROM sakila.film JOIN sakila.film_category ON film.film_id = film_category.film_id JOIN sakila.category ON category.category_id = film_category.category_id
    WHERE title NOT LIKE "%x%" AND title NOT LIKE "%q%" AND title NOT LIKE "%v%";
    
INSERT INTO zagrali (Film, Aktor)
	SELECT sakila.film_actor.film_id, sakila.film_actor.actor_id
    FROM sakila.film_actor
    WHERE sakila.film_actor.film_id IN (SELECT ID FROM filmy) AND sakila.film_actor.actor_id IN (SELECT ID FROM aktorzy);
    
#3
ALTER TABLE aktorzy ADD IleFilmów int;
ALTER TABLE aktorzy ADD Tytuły varchar(256);
UPDATE aktorzy SET IleFilmów = (SELECT count(Film) FROM zagrali WHERE zagrali.Aktor=aktorzy.ID GROUP BY zagrali.Aktor);
UPDATE aktorzy SET Tytuły = (
	SELECT GROUP_CONCAT(filmy.Tytuł SEPARATOR ', ') FROM filmy JOIN zagrali ON filmy.ID=zagrali.Film WHERE aktorzy.ID=zagrali.Aktor AND aktorzy.IleFilmów<12 GROUP BY zagrali.Aktor);

#4
CREATE TABLE Agenci(
	licencja varchar(30) PRIMARY KEY,
    nazwa varchar(90),
    wiek int CHECK(wiek>20),
    typ ENUM ('osoba indywidualna', 'agencja', 'inny')
    );

CREATE TABLE Kontrakty(
	ID int PRIMARY KEY auto_increment,
    agent varchar(30) REFERENCES Agenci(licencja) ON DELETE CASCADE,
    aktor int REFERENCES aktorzy(ID)  ON DELETE CASCADE,
    początek date, 
    koniec date CHECK (koniec >= początek + interval 1 day),
    gaża int CHECK (gaża>0)
    );

#5
DELIMITER $$
CREATE PROCEDURE nowiAgenci ()
BEGIN
DECLARE x INT;
DECLARE y float;
SET x =2;
label: WHILE x<=1002 DO
SET y = RAND()*3;
IF x<10 THEN
INSERT INTO agenci (licencja, nazwa, wiek, typ) VALUES
	(concat('LIC/0/1/2/0000', x), concat('Agent', x), RAND()*45+21, ceiling(y));
ELSEIF x>=10 AND x<100 THEN
INSERT INTO agenci (licencja, nazwa, wiek, typ) VALUES
	(concat('LIC/0/1/2/000', x), concat('Agent', x), RAND()*45+21, ceiling(y));
ELSEIF x>=100 AND x<1000 THEN
INSERT INTO agenci (licencja, nazwa, wiek, typ) VALUES
	(concat('LIC/0/1/2/00', x), concat('Agent', x), RAND()*45+21, ceiling(y)); 
ELSE
INSERT INTO agenci (licencja, nazwa, wiek, typ) VALUES
	(concat('LIC/0/1/2/0', x), concat('Agent', x), RAND()*45+21, ceiling(y)); 
END If;
SET x = x+1;
END WHILE label;
END $$
DELIMITER ;

CALL nowiAgenci();

DELIMITER $$
CREATE PROCEDURE nowekontrakty()
BEGIN
DECLARE x INT;
DECLARE agent INT;
SET x = 1;
WHILE x<=200 DO
IF x IN (SELECT ID FROM aktorzy) THEN 
	SET agent = ceiling(RAND()*1002); 
	IF agent<10 THEN
		INSERT INTO Kontrakty (agent, aktor, początek, koniec, gaża) VALUES
			(concat("LIC/0/1/2/0000",agent), x, date_sub(curdate(), interval RAND()*500 DAY ), date_add(curdate(), interval RAND()*500 DAY), 5000+RAND()*20000);
    ELSEIF agent>=10 AND agent<100 THEN
		INSERT INTO Kontrakty (agent, aktor, początek, koniec, gaża) VALUES
			(concat("LIC/0/1/2/000",agent), x, date_sub(curdate(), interval RAND()*500 DAY ), date_add(curdate(), interval RAND()*500 DAY), 5000+RAND()*20000);
	ELSEIF agent>=100 AND agent<1000 THEN
		INSERT INTO Kontrakty (agent, aktor, początek, koniec, gaża) VALUES
			(concat("LIC/0/1/2/00",agent), x, date_sub(curdate(), interval RAND()*500 DAY ), date_add(curdate(), interval RAND()*500 DAY), 5000+RAND()*20000);
	ELSE
		INSERT INTO Kontrakty (agent, aktor, początek, koniec, gaża) VALUES
			(concat("LIC/0/1/2/0",agent), x, date_sub(curdate(), interval RAND()*500 DAY ), date_add(curdate(), interval RAND()*500 DAY), 5000+RAND()*20000);
	END IF;
END IF;
SET x= x+1;
END WHILE;
END $$
DELIMITER ;
call nowekontrakty();

select * from kontrakty;
select * from aktorzy;
#7
DELIMITER $$
CREATE FUNCTION aktualnyKontrakt(imię_in varchar(30), nazwisko_in varchar(30)) RETURNS varchar(30) DETERMINISTIC
BEGIN
DECLARE agen varchar(30);
DECLARE dni INT;
DECLARE result varchar(30) default "";

SELECT agenci.nazwa AS agent  FROM aktorzy JOIN kontrakty ON aktorzy.ID = kontrakty.aktor JOIN agenci ON agenci.licencja = kontrakty.agent WHERE imię = imię_in AND nazwisko = nazwisko_in INTO agen;
SELECT TIMESTAMPDIFF(DAY, curdate(), koniec) from aktorzy JOIN kontrakty ON aktorzy.ID = kontrakty.aktor JOIN agenci ON agenci.licencja = kontrakty.agent WHERE imię = imię_in AND nazwisko = nazwisko_in INTO dni;

SET result = concat ( agen, " - ", dni);
IF result IS NULL THEN 
	SET result = "Brak aktora w bazie";
END IF;

RETURN result;
END $$
DELIMITER ;
select aktualnykontrakt('Penelope', 'Guine');

#8
USE DELIMITER $$
CREATE FUNCTION średniaWartośćKontraktu(lic_in varchar(30)) RETURNS FLOAT DETERMINISTIC
BEGIN

DECLARE result FLOAT;

IF (lic_in NOT IN (SELECT agent from kontrakty WHERE koniec>curdate())) THEN
	RETURN NULL;
END IF;

SELECT avg(gaża) FROM kontrakty WHERE agent = lic_in AND koniec>curdate() GROUP BY agent INTO result;

RETURN result;

END$$
USE DELIMITER ;
select średniaWartośćKontraktu('LIC/0/1/2/00749');

#9
SET @str = 'SELECT count(AK) AS LiczbaAktorów, AG from (SELECT distinct aktor AS AK, agent AS AG FROM kontrakty) AS DIS WHERE AG = ? group by AG';
PREPARE LiczbaAktorów FROM @str;
SET @lic = 'LIC/0/1/2/00749';
EXECUTE LiczbaAktorów USING @lic;

#10
USE DELIMITER $$
CREATE PROCEDURE najdłuższaWspółpraca ( OUT lic varchar(30), OUT akt INT) deterministic
BEGIN



END$$
USE DELIMITER ;


#14
CREATE OR REPLACE VIEW dniDoKońca AS
	SELECT Imię, Nazwisko, agenci.nazwa, TIMESTAMPDIFF(DAY, curdate(), koniec) FROM aktorzy JOIN kontrakty ON kontrakty.aktor = aktorzy.id JOIN agenci ON agenci.licencja = kontrakty.agent;
select * from dniDoKońca;



