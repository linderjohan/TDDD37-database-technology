
/* // TABLE AIRPORT */
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Contact;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Weekly_schedule;
DROP TABLE IF EXISTS Weekday;
DROP TABLE IF EXISTS Route;
DROP TABLE IF EXISTS Year;
DROP TABLE IF EXISTS Airport;


CREATE TABLE Airport (
  airport_code VARCHAR(3) NOT NULL,
  name VARCHAR(30) NOT NULL,
  country VARCHAR(30) NOT NULL,
  PRIMARY KEY (airport_code)
);

/* DONE */

/* Table Year */

CREATE TABLE Year (
	year INT NOT NULL,
	profit_factor DOUBLE NOT NULL,
	PRIMARY KEY (year)
);
	/* Table Route */

CREATE TABLE Route (
  route_id INT NOT NULL AUTO_INCREMENT,
  departure VARCHAR(3) NOT NULL,
  arrival VARCHAR(3) NOT NULL,
  year INT NOT NULL,
  price DOUBLE NOT NULL,
  PRIMARY KEY (route_id),
  CONSTRAINT fk_route_dep
    FOREIGN KEY (departure)
    REFERENCES Airport (airport_code)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_route_arr
    FOREIGN KEY (arrival)
    REFERENCES Airport (airport_code)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
	CONSTRAINT fk_route_year
		FOREIGN KEY (year)
		REFERENCES Year (year),
	CONSTRAINT uq_yearly_route UNIQUE(departure, arrival, year)
);

/* Done */


/* Weekday */
DROP TABLE IF EXISTS Weekly_schedule;
DROP TABLE IF EXISTS Weekday;


CREATE TABLE Weekday (
	day VARCHAR(10) NOT NULL,
	year INT NOT NULL,
	weekday_factor DOUBLE NOT NULL,
	CONSTRAINT fk_weekday_year
		FOREIGN KEY (year)
		REFERENCES Year (year)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT uq_day_in_year UNIQUE(day, year)
);


/* Weekly schedule */

CREATE TABLE Weekly_schedule (
	id INT NOT NULL AUTO_INCREMENT,
	route INT NOT NULL,
	weekday VARCHAR(10) NOT NULL,
	year INT NOT NULL,
	departure_time TIME NOT NULL,
	PRIMARY KEY (id),
	CONSTRAINT fk_weekly_route
		FOREIGN KEY (route)
		REFERENCES Route (route_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_weekly_day
		FOREIGN KEY (weekday, year)
		REFERENCES Weekday (day, year)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT uq_route_on_day_year UNIQUE (route, weekday, year)	
);

/* @TODO Kanske ändra så även departure_time är unik? */


/* Table Flight */
CREATE TABLE Flight (
	flight_number INT NOT NULL AUTO_INCREMENT,
	schedule INT NOT NULL,
	week INT NOT NULL,
  PRIMARY KEY (flight_number),
	CONSTRAINT fk_flight_schedule
		FOREIGN KEY (schedule)
		REFERENCES Weekly_schedule (id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

/* Table Reservation */

CREATE TABLE Reservation (
	reservation_number INT NOT NULL,
	number_of_passengers INT NOT NULL,
	flight_number INT NOT NULL,
	PRIMARY KEY (reservation_number),
	CONSTRAINT fk_reservation_fl_number
		FOREIGN KEY (flight_number)
		REFERENCES Flight (flight_number) 
		ON DELETE CASCADE
		ON UPDATE CASCADE
);



/* Table Payment */

CREATE TABLE Payment (
	reservation_number INT NOT NULL,
	card_holder VARCHAR(30),
	card_number INT NOT NULL,
	price DOUBLE NOT NULL,
	PRIMARY KEY (reservation_number),
	CONSTRAINT fk_payment_rsv_number
		FOREIGN KEY (reservation_number)
		REFERENCES Reservation (reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);


/* Table Passenger */

CREATE TABLE Passenger (
	passport_number INT NOT NULL,
	reservation_number INT NOT NULL,
	name VARCHAR(43) NOT NULL,
	CONSTRAINT fk_passenger_res_number
		FOREIGN KEY (reservation_number)
		REFERENCES Reservation (reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT uq_passenger_on_reseration UNIQUE(passport_number, reservation_number)
);

/* Table contact */
CREATE TABLE Contact (
	passport_number INT NOT NULL,
	reservation_number INT NOT NULL,
	name VARCHAR(43) NOT NULL,
	email VARCHAR(43) NOT NULL,
	CONSTRAINT fk_contact_passp_number
		FOREIGN KEY (passport_number)
		REFERENCES Passenger (passport_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_contact_res_number
		FOREIGN KEY (reservation_number)
		REFERENCES Reservation (reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT uq_contact_on_reservation UNIQUE(passport_number, reservation_number)
);


/* Table Ticket */

CREATE TABLE Ticket (
	ticket_number INT NOT NULL,
	passport_number INT NOT NULL,
	reservation_number INT NOT NULL,
	PRIMARY KEY (ticket_number),
	CONSTRAINT fk_ticket_passenger
		FOREIGN KEY (passport_number, reservation_number)
		REFERENCES Passenger (passport_number, reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT uq_ticket_passenger UNIQUE(passport_number, reservation_number)
);


/* PROCEDURES */

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;


delimiter //
CREATE PROCEDURE addYear(IN year INT, IN factor DOUBLE)
BEGIN
	INSERT INTO Year VALUES (year, factor);
END
//
delimiter ;

/* CALL addYear(2012, 1.5); */

SELECT * FROM Year; 

delimiter //
CREATE PROCEDURE addDay(IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
	INSERT INTO Weekday VALUES(day, year, factor);
END
//

CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
	INSERT INTO Airport VALUES (airport_code, name, country);
END
// 

CREATE PROCEDURE addRoute(IN departure VARCHAR(3), IN arrival VARCHAR(3), IN year INT, IN route_price DOUBLE)
BEGIN
	INSERT INTO Route (departure, arrival, year, price) VALUES (departure, arrival, year, route_price);
END
//

CREATE PROCEDURE addFlight(IN departure VARCHAR(3) , IN arrival VARCHAR(3), IN year INT, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
	declare r_id INT;
	declare flight_day VARCHAR(10);
   declare w_id INT;
	declare week_no INT;

	SELECT route_id INTO r_id FROM Route WHERE (Route.departure = departure AND Route.arrival = arrival AND Route.year = year);
	SELECT day INTO flight_day FROM Weekday WHERE (Weekday.day = day AND Weekday.year = year);

	INSERT INTO Weekly_schedule (route, weekday, year, departure_time) VALUES (r_id, flight_day, year, departure_time);
	
	
	
	SELECT id INTO w_id FROM Weekly_schedule WHERE (Weekly_schedule.route = r_id AND Weekly_schedule.weekday = flight_day AND Weekly_schedule.year = year);
	
	
	set week_no = 1;
	WHILE week_no <= 52 DO
		INSERT INTO Flight (schedule, week) VALUES (w_id, week_no);
		set week_no = week_no + 1;
	END WHILE;
END
//




delimiter ;

/* CALL addDay("Måndag", 2012);
CALL addDestination(); */



/* Functions */
DROP FUNCTION IF EXISTS calcFreeSeats;
DROP FUNCTION IF EXISTS calcPrice;

/* Calculate free seats */ 5658 = 1600 * 1.5 * 20/40 * 2.3

delimiter //
CREATE FUNCTION calcFreeSeats(flight_number INT) returns INT
BEGIN
	declare f_seats INT;

	SELECT (40 - COUNT(number_of_passengers)) INTO f_seat FROM Reservation
		INNER JOIN Payment ON
		Payment.reservation_number = Reservation.reservation_number
		INNER JOIN Flight ON
		Flight.schedule = Reservation.flight_number
		WHERE Flight.flight_number = flight_number;

	return f_seats;
END
//

/* Calc price */	

CREATE FUNCTION calcPrice(flight_number INT) returns DOUBLE
BEGIN
	declare r_price DOUBLE;
	declare d_factor DOUBLE;
	declare p_factor DOUBLE;
	declare booked_seats INT;
	/* set booked_seats = 40 - calcFreeSeats(flight_number); */
	set booked_seats = 40;

	SELECT price INTO r_price FROM Route
		INNER JOIN Weekly_schedule ON
		Weekly_schedule.route = Route.route_id
		INNER JOIN Flight ON
		Flight.schedule = Weekly_schedule.id
		WHERE Flight.flight_number = flight_number;

	SELECT weekday_factor INTO d_factor FROM Weekday
		INNER JOIN Weekly_schedule ON
		(Weekly_schedule.weekday = Weekday.day AND
		Weekly_schedule.year = Weekday.year)
		INNER JOIN Flight ON
		Flight.schedule = Weekly_schedule.id
		WHERE Flight.flight_number = flight_number;

	SELECT profit_factor INTO p_factor FROM Year
		INNER JOIN Weekly_schedule ON
		Weekly_schedule.year = Year.year
		INNER JOIN Flight ON
		Flight.schedule = Weekly_schedule.id
		WHERE Flight.flight_number = flight_number;

	return r_price * d_factor * (booked_seats + 1) / 40 * p_factor;


END
//
