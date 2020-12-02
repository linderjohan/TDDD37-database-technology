
/* // TABLE AIRPORT */
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Has_reservation;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Contact;	
DROP TABLE IF EXISTS Passenger;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Weekly_schedule;
DROP TABLE IF EXISTS Weekday;
DROP TABLE IF EXISTS Route;
DROP TABLE IF EXISTS Year;
DROP TABLE IF EXISTS Airport;


DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;



DROP FUNCTION IF EXISTS calcFreeSeats;
DROP FUNCTION IF EXISTS calcPrice;


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
	CONSTRAINT uq_route_on_day_year UNIQUE (route, weekday, year, departure_time)	
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




/* Table Passenger */

CREATE TABLE Passenger (
	passport_number INT NOT NULL,
	name VARCHAR(30) NOT NULL,
	PRIMARY KEY (passport_number)
);


/* Table contact */
CREATE TABLE Contact (
	passport_number INT NOT NULL,
	phone BIGINT NOT NULL,
	email VARCHAR(30) NOT NULL,
	PRIMARY KEY (passport_number),
	CONSTRAINT fk_contact_passp_number
		FOREIGN KEY (passport_number)
		REFERENCES Passenger (passport_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);


/* Table Reservation */

CREATE TABLE Reservation (
	reservation_number INT NOT NULL AUTO_INCREMENT,
	contact INT,
	flight_number INT NOT NULL,
	number_of_passengers INT NOT NULL,
	PRIMARY KEY (reservation_number),
	CONSTRAINT fk_reservation_contact
		FOREIGN KEY (contact)
		REFERENCES Contact (passport_number) 
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_reservation_fl_number
		FOREIGN KEY (flight_number)
		REFERENCES Flight (flight_number) 
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

/* Table has  reservation */

CREATE TABLE Has_reservation (
	passport_number INT NOT NULL,
	reservation_number INT NOT NULL,
	PRIMARY KEY (passport_number, reservation_number),
	CONSTRAINT fk_has_reservation_pass_no
		FOREIGN KEY (passport_number)
		REFERENCES Passenger (passport_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_has_reservation_res_no
		FOREIGN KEY (reservation_number)
		REFERENCES Reservation (reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

/* Table Booking */

CREATE TABLE Booking (
	reservation_number INT NOT NULL,
	card_holder VARCHAR(30) NOT NULL,
	card_number BIGINT NOT NULL,
	price DOUBLE NOT NULL,
	PRIMARY KEY (reservation_number),
	CONSTRAINT fk_booking_rsv_number
		FOREIGN KEY (reservation_number)
		REFERENCES Reservation (reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

/* Table Ticket */

CREATE TABLE Ticket (
	ticket_number INT NOT NULL,
	passport_number INT NOT NULL,
	reservation_number INT NOT NULL,
	PRIMARY KEY (ticket_number),
	CONSTRAINT fk_ticket_passenger
		FOREIGN KEY (passport_number)
		REFERENCES Passenger (passport_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fk_ticket_reservation_number
		FOREIGN KEY (reservation_number)
		REFERENCES Booking (reservation_number)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT uq_ticket_passenger UNIQUE(passport_number, reservation_number)
);


/* PROCEDURES */

delimiter //
CREATE PROCEDURE addYear(IN year INT, IN factor DOUBLE)
BEGIN
	INSERT INTO Year VALUES (year, factor);
END
//

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
	DECLARE r_id INT;
	DECLARE flight_day VARCHAR(10);
	DECLARE w_id INT;
	DECLARE week_no INT;

	SELECT route_id INTO r_id FROM Route WHERE (Route.departure = departure AND Route.arrival = arrival AND Route.year = year);
	SELECT day INTO flight_day FROM Weekday WHERE (Weekday.day = day AND Weekday.year = year);

	INSERT INTO Weekly_schedule (route, weekday, year, departure_time) VALUES (r_id, flight_day, year, departure_time);
	
	SET w_id = LAST_INSERT_ID();
	
	SET week_no = 1;
	WHILE week_no <= 52 DO
		INSERT INTO Flight (schedule, week) VALUES (w_id, week_no);
		SET week_no = week_no + 1;
	END WHILE;
END
//

/* Add reservation */
CREATE PROCEDURE addReservation(IN departure VARCHAR(3), IN arrival VARCHAR(3), IN year INT, IN week INT , IN day VARCHAR(10), IN time TIME, IN number_of_passengers INT, OUT out_reservation_nr INT)
BEGIN
	DECLARE f_number INT;
	DECLARE r_id INT; 
	DECLARE w_schedule_id INT;
	DECLARE temp INT;
	SELECT route_id INTO r_id FROM Route AS R WHERE
		(R.departure = departure AND R.arrival = arrival AND R.year = year);

	SELECT id INTO w_schedule_id FROM Weekly_schedule AS Ws WHERE
		(Ws.route = r_id AND Ws.weekday = day AND Ws.year = year AND Ws.departure_time = time);

	SELECT flight_number INTO f_number FROM Flight AS F WHERE	
		(F.schedule = w_schedule_id AND F.week = week);
	

	IF f_number IS NULL OR r_id IS NULL OR w_schedule_id IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  "There exist no flight for the given route, date and time"; 
	
	ELSEIF number_of_passengers > calcFreeSeats(f_number) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There are not enough seats available on the chosen flight";
	ELSE
		INSERT INTO Reservation (flight_number, number_of_passengers) VALUES (f_number, number_of_passengers);
		SET out_reservation_nr = LAST_INSERT_ID(); /* SQL built in function to get last inserted id*/
	END IF;
END
//

/* Add passenger */
/* @TODO check if passenger already exists */
CREATE PROCEDURE addPassenger(IN reservation_nr INT, IN passport_number INT, IN name VARCHAR(30))
BEGIN

	IF (SELECT reservation_number FROM Reservation AS R WHERE R.reservation_number = reservation_nr) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The given reservation number does not exist";
	
	ELSEIF (SELECT reservation_number FROM Booking WHERE reservation_number = reservation_nr) IS NOT NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The booking has already been payed and no futher passengers can be added";
	ELSE
		INSERT INTO Passenger VALUES (passport_number, name) ON DUPLICATE KEY UPDATE passport_number = passport_number, name = name;
		INSERT INTO Has_reservation VALUES (passport_number, reservation_nr);
	END IF;	
END
//

/* Add contact */

CREATE PROCEDURE addContact(IN reservation_nr INT, IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
	IF (SELECT passport_number FROM Passenger AS P WHERE P.passport_number = passport_number) IS NULL THEN	
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The person is not a passenger of the reservation";
	
	ELSEIF (SELECT reservation_number FROM Reservation AS R WHERE R.reservation_number = reservation_nr) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The given reservation number does not exist";

	ELSE
		INSERT INTO Contact VALUES (passport_number, phone, email);
		UPDATE Reservation SET Reservation.contact = passport_number WHERE reservation_number = reservation_nr;
	END IF;
END
//


/* addPayment (reservation_nr, cardholder_name, credit_card_number); */
/* Add payment */

CREATE PROCEDURE addPayment(IN reservation_nr INT, IN cardholder_name VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
	DECLARE price DOUBLE;
	DECLARE f_number INT;
	IF (SELECT reservation_number FROM Reservation AS R WHERE R.reservation_number = reservation_nr) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The given reservation number does not exist";
	
	ELSEIF (SELECT contact FROM Reservation AS R WHERE R.reservation_number = reservation_nr) IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The reservation has no contact yet";
	ELSE
	
	
		SELECT F.flight_number INTO f_number FROM Flight AS F INNER JOIN
			Reservation AS R ON R.flight_number = F.flight_number WHERE 
			R.reservation_number = reservation_nr;
		
		/*  */
		
		IF(calcFreeSeats(f_number) < (SELECT COUNT(passport_number) FROM Has_reservation AS Hr WHERE Hr.reservation_number = reservation_nr)) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There are not enough seats available on the flight anymore, deleting reservation";
			DELETE FROM Reservation WHERE reservation_number = reservation_nr; 
		ELSE
			SET price = calcPrice(1);
			INSERT INTO Booking VALUES (reservation_nr, cardholder_name, credit_card_number, price);
		/* TRIGGER! generate ticket */
		END IF;
	END IF;
END
//



/* Functions */

/* Calculate free seats */


CREATE FUNCTION calcFreeSeats(flight_number INT) returns INT
BEGIN
	DECLARE f_seats INT;

	SELECT (40 - COUNT(number_of_passengers)) INTO f_seats FROM Reservation
		INNER JOIN Booking ON
		Booking.reservation_number = Reservation.reservation_number
		INNER JOIN Flight ON
		Flight.schedule = Reservation.flight_number
		WHERE Flight.flight_number = flight_number;

	return f_seats;
END
//

/* Calc price */	

CREATE FUNCTION calcPrice(flight_number INT) returns DOUBLE
BEGIN
	DECLARE r_price DOUBLE;
	DECLARE d_factor DOUBLE;
	DECLARE p_factor DOUBLE;
	DECLARE booked_seats INT;
	SET booked_seats = 40 - calcFreeSeats(flight_number);


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
