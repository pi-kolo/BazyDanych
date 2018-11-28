USE `laboratorium-filmoteka`;

Show index from agenci;
show index from aktorzy;
show index from zagrali;
show index from filmy;

CREATE index tytul_idx ON filmy (Tytuł);
CREATE index nazwIm_idx ON aktorzy (Nazwisko, Imię(1));
CREATE index aktor_idx ON zagrali (aktor);
#2
CREATE index koniec_idx USING BTREE ON kontrakty (koniec);
EXPLAIN SELECT imię, nazwisko, koniec FROM kontrakty JOIN aktorzy ON aktorzy.ID=kontrakty.aktor 
	WHERE koniec between curdate() AND adddate(curdate(), interval 1 month);
    
#3
#1)
SELECT imię from aktorzy where imię LIKE "J%"; #nie używa, bo nie ma na imionach
#2)
SELECT nazwisko from aktorzy WHERE IleFilmów >12; #nie
#3)
SELECT tytuł from filmy JOIN zagrali ON filmy.ID=zagrali.film JOIN aktorzy ON zagrali.aktor=aktorzy.ID;


#4
CREATE DATABASE if not exists dowolnanazwa;	
use dowolnanazwa;

CREATE TABLE Ludzie (
	PESEL char(11) PRIMARY KEY,
    imię varchar(30),
    nazwisko varchar(30),
    data_urodzenia date,
    wzrost float,
    waga float,
    rozmiar_buta int,
    ulubiony_kolor enum('czarny', 'czerwony', 'zielony', 'niebieski', 'biały')
    );

CREATE TABLE Pracownicy (
	PESEL char(11) PRIMARY KEY,
    zawód varchar(50),
    pensja float
    );
    
DELIMITER $$
CREATE TRIGGER ludzie_dodatni BEFORE INSERT ON Ludzie
FOR EACH ROW
BEGIN
    IF (NEW.wzrost < 0 OR NEW.waga < 0 OR NEW.rozmiar_buta<0) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jedna z tych wartości ujemna: wzrost, waga lub rozmiar buta';
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER pracownicy_dorosli BEFORE INSERT ON Pracownicy
FOR EACH ROW
BEGIN
	IF (SELECT data_urodzenia FROM Ludzie JOIN Pracownicy ON Ludzie.PESEL=Pracownicy.PESEL WHERE Ludzie.PESEL=NEW.PESEL) < subdate(curdate(), interval 18 year) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pracownik musi być dorosły';
        END IF;
END$$
DELIMITER ;    
INSERT INTO Ludzie VALUES ('12233443334', 'JAN', 'Kowalski', '2010-10-11', 100, 100, 10, 3);
SELECT * from ludzie;
INSERT INTO Pracownicy VALUES ('12233493334', 'elektryk', 32233);
select * from pracownicy;

	
DELIMITER $$
CREATE PROCEDURE wstawLudzi()
BEGIN
DECLARE I INT;
DECLARE urodzenie date;
DECLARE a int;
declare b int;
declare c int; 
declare d int;
declare ostatnia int;
SET I=0;
WHILE I<200 DO
SET urodzenie=adddate('1960-05-18', INTERVAL 18000*rand() DAY);
set a=ceiling(RAND()*9); 
set b=ceiling(rand()*9);
set c=ceiling(RAND()*9);
set d=ceiling(RAND()*9);
If YEAR(urodzenie)<=2000 THEN
set ostatnia=MOD(9*substring(urodzenie,3,1)+7*substring(urodzenie,4,1)+3*substring(urodzenie, 6,1)+1*substring(urodzenie, 7,1)+ 9*substring(urodzenie,9,1)+ 7*substring(urodzenie,10,1) +3*a+9*b+1*c+7*d, 10);
INSERT INTO Ludzie (imię, nazwisko, wzrost, waga, ulubiony_kolor, rozmiar_buta, data_urodzenia, PESEL) VALUES 
	(elt(ceiling(RAND()*10),'Jan', 'Adam', 'Piotr', 'Paweł', 'Bartosz', 'Ignacy', 'Anna', 'Magda', 'Jolanta', 'Karol', 'Edmund', 'Henryk', 'Stanisław', 'Helena', 'Romeo', 'Julia', 'Grzegorz', 'Kamil', 'Jacek', 'Szymon' ), elt(ceiling(rand()*11),'Kowalski', 'Nowak', 'Okoń', 'Karaś', 'Oczko', 'Drzewo', 'Owca', 'Ciastko', 'Żrebię', 'Woda', 'Dzban', 'Płotka', 'Róża', 'Czajnik', 'Szafa', 'Młot', 'Kaktus', 'Stół', 'Kalkulator' ), 150+50*rand(), 50+50*rand(), ceiling(rand()*5), ceiling(36+11*rand()), urodzenie, 
		concat(substring(urodzenie, 3,2), substring(urodzenie, 6,2), substring(urodzenie, 9,2), a,b,c,d, ostatnia) );
ELSE
 set ostatnia=MOD(9*substring(urodzenie,3,1)+7*substring(urodzenie,4,1)+3*(substring(urodzenie, 6,1)+2)+1*substring(urodzenie, 7,1)+ 9*substring(urodzenie,9,1)+ 7*substring(urodzenie,10,1) +3*a+9*b+1*c+7*d, 10);
	INSERT INTO Ludzie (imię, nazwisko, wzrost, waga, ulubiony_kolor, rozmiar_buta, data_urodzenia, PESEL) VALUES 
	(elt(ceiling(RAND()*10),'Jan', 'Adam', 'Piotr', 'Paweł', 'Bartosz', 'Ignacy', 'Anna', 'Magda', 'Jolanta', 'Karol','Edmund', 'Henryk', 'Stanisław', 'Helena', 'Romeo', 'Julia', 'Grzegorz', 'Kamil', 'Jacek', 'Szymon' ), elt(ceiling(rand()*11),'Kowalski', 'Nowak', 'Okoń', 'Karaś', 'Oczko', 'Drzewo', 'Owca', 'Ciastko', 'Żrebię', 'Woda', 'Dzban', 'Płotka', 'Róża', 'Czajnik', 'Szafa', 'Młot', 'Kaktus', 'Stół', 'Kalkulator' ), 150+50*rand(), 50+50*rand(), ceiling(rand()*5), ceiling(36+11*rand()), urodzenie, 
		concat(substring(urodzenie, 3,2), substring(urodzenie, 6,2)+20, substring(urodzenie, 9,2), a,b,c,d, ostatnia) );
		END IF;
		SET I=I+1;
END WHILE;
END$$
DELIMITER ;	
delete from ludzie;
call wstawludzi();
use dowolnanazwa;
drop procedure wstawludzi;
select * from ludzie;
#Dodajmy pracowników samhał
DELIMITER $$
CREATE PROCEDURE dodajPracowników()
BEGIN
DECLARE x INT;
DECLARE tmpPSL char(11);
DECLARE kursorPSL CURSOR FOR (SELECT PESEL FROM Ludzie);
OPEN kursorPSL;
SET x=0;
WHILE x<77 DO
FETCH  kursorPSL INTO tmpPSL;
IF (substr(tmpPSL,1,2)>53 AND tmpPSL NOT IN (SELECT PESEL FROM Pracownicy) )THEN
	INSERT INTO Pracownicy VALUES (tmpPSL, 'sprzedawca', 2000+3000*RAND());
    SET x=x+1;
END IF;
END WHILE;
CLOSE kursorPSL;
OPEN kursorPSL;
SET x=0;
WHILE x<50 DO
FETCH kursorPSL INTO tmpPSL;
IF(substr(tmpPSL, 1, 2) > 18 AND tmpPSL NOT IN (SELECT PESEL FROM Pracownicy)) THEN
	INSERT INTO PRACOWNICY VALUES (tmpPSL, 'aktor', 5000+RAND()*30000);
    set x=x+1;
END IF;
END WHILE;
CLOSE kursorPSL;
OPEN kursorPSL;
SET x=0;
WHILE x<33 DO
FETCH kursorPSL INTO tmpPSL;
IF(substr(tmpPSL, 1, 2) >18 AND tmpPSL NOT IN (SELECT PESEL FROM Pracownicy)) THEN
	INSERT INTO Pracownicy VALUES (tmpPSL, 'agent', 4000+10000*RAND());
    SET x=x+1;
END IF;
END WHILE;
CLOSE kursorPSL;
OPEN kursorPSL;
SET x=0;
WHILE x<13 DO
FETCH kursorPSL INTO tmpPSL;
IF(substr(tmpPSL,1,2) >18 AND tmpPSL NOT IN (SELECT PESEL FROM Pracownicy)) THEN
	INSERT INTO Pracownicy VALUES (tmpPSL, 'Informatyk', 8000+RAND()*15000);
	SET x=x+1;
END IF;
END WHILE;
CLOSE kursorPSL;
OPEN kursorPSL;
SET x=0;
WHILE x<2 DO
FETCH kursorPSL INTO tmpPSL;
IF(substr(tmpPSL,1,2) > 18 AND tmpPSL NOT IN (SELECT PESEL FROM PRACOWNICY)) THEN
	INSERT INTO Pracownicy VALUES (tmpPSL, 'Reporter', 5000+RAND()*5000);
    SET x=x+1;
END IF;
END WHILE;
CLOSE kursorPSL;

END$$
DELIMITER ;
call dodajpracowników();
select * from pracownicy;
delete from pracownicy;
INSERT INTO Ludzie VALUES ('45010112234', 'maria', 'db', '1945-01-01', 134, 45, 40, 3);
drop procedure dodajpracowników;

select sum(ulubiony_kolor) from ludzie group by ulubiony_kolor;

#5
DELIMITER $$
CREATE PROCEDURE agreguj ( IN agg varchar(20), IN kol enum('PESEL', 'Imię', 'Nazwisko', 'data_urodzenia', 'wzrost', 'waga', 'rozmmiar_buta', 'ulubiony_kolor'))
BEGIN
DECLARE X varchar(30);
CASE agg
	WHEN 'sum' THEN
    SET @str = concat('SELECT sum( ', kol, ') from Ludzie into @temp');
    PREPARE statement from @str;
    EXECUTE statement;
    
    WHEN 'avg' THEN
    SET @str = concat('SELECT avg( ', kol, ') from Ludzie into @temp');
    PREPARE statement from @str;
    EXECUTE statement;
    
    WHEN 'count' THEN
    SET @str = concat('SELECT count( ', kol, ') from Ludzie into @temp');
    PREPARE statement from @str;
    EXECUTE statement;
    
    WHEN 'max' THEN
    SET @str = concat('SELECT MAX( ', kol, ') from Ludzie into @temp');
    PREPARE statement from @str;
    EXECUTE statement;

	WHEN 'min' THEN
    SET @str = concat('SELECT min( ', kol, ') from Ludzie into @temp');
    PREPARE statement from @str;
    EXECUTE statement;
    
    ELSE
		  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'niepoprawna agregacja, wybierz spośród: avg, min, max, sum, count';
END CASE;
SET X = @temp;
SELECT X;
END$$
DELIMITER ;
select ulubiony_kolor, count(ulubiony_kolor) from ludzie group by ulubiony_kolor;
call agreguj('avg', 8);
drop procedure agreguj;

SELECT sum(pensja) from pracownicy where pracownicy.zawód='aktor';

#6
DELIMITER $$
CREATE PROCEDURE wypłaty( IN budżet float, IN zawód varchar(20))
BEGIN
DECLARE pensjaT float;
DECLARE PESELT char(11);
DECLARE wypłacalne INT default 1;
DECLARE done INT DEFAULT FALSE;
DECLARE pensjeK CURSOR FOR (SELECT PESEL, pensja FROM Pracownicy WHERE Pracownicy.zawód=zawód);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
#IF ((SELECT sum(pensja) from pracownicy where pracownicy.zawód=zawód) > budżet) THEN
#	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Za mało pieniążków na wypłaty';
OPEN pensjeK;
set @bud=budżet;
CREATE TEMPORARY TABLE temp ( PESEL char(11), wypłacone BOOLEAN);
START TRANSACTION;
loop1: LOOP 
	FETCH pensjeK INTO PESELT, pensjaT;
		IF done THEN
		LEAVE loop1;
		END IF;
	set @bud = @bud - pensjaT;
	IF(@bud<0) THEN
		SET wypłacalne=0;
		leave loop1;
	ELSE
		INSERT INTO temp VALUES (concat('********', substr(PESELT,9)), TRUE);
	END IF;
END LOOP;
CLOSE pensjeK;
IF(wypłacalne=1) THEN
	COMMIT;
	SELECT * FROM temp;	
    drop temporary table temp;
ELSE 
	drop temporary table temp;
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='Za mało pieniążków na wypłaty';
    
END IF;

END$$
DELIMITER ;
call wypłaty (10000000, 'aktor');
drop procedure wypłaty;
drop temporary table temp;

CREATE DATABASE logi;
CREATE TABLE logi.logi (
	PESEL char(11),
    StaraPensja FLOAT,
    NowaPensja FLOAT,
    DataZmiany datetime,
    Użytkownik varchar(50)
    );

DELIMITER $$
CREATE TRIGGER updatePensja AFTER UPDATE ON dowolnanazwa.pracownicy
FOR EACH ROW
BEGIN
	INSERT INTO logi.logi VALUES(
		OLD.PESEL, OLD.pensja, NEW.pensja, now(), user()
        );
END$$
DELIMITER ;

UPDATE pracownicy set pensja = 12320 WHERE PESEL LIKE '%34';
select * from logi.logi;
