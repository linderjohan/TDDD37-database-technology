
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

DROP TRIGGER IF EXISTS createTickets;
DROP VIEW IF EXISTS allFlights;


/* Table Airport */
CREATE TABLE Airport (
  airport_code VARCHAR(3) NOT NULL,
  name VARCHAR(30) NOT NULL,
  country VARCHAR(30) NOT NULL,
  PRIMARY KEY (airport_code)
);


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


/* Table Weekday */ 
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


/* TABLE Weekly_schedule */
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
		INSERT INTO Contact VALUES (passport_number, phone, email) ON DUPLICATE KEY UPDATE email = email, phone = phone;
		UPDATE Reservation SET Reservation.contact = passport_number WHERE reservation_number = reservation_nr;
	END IF;
END
//


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
			
		
		IF(calcFreeSeats(f_number) < (SELECT COUNT(passport_number) FROM Has_reservation AS Hr WHERE Hr.reservation_number = reservation_nr)) THEN
			DELETE FROM Reservation WHERE Reservation.reservation_number = reservation_nr; 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There are not enough seats available on the flight anymore, deleting reservation";
		ELSE
			SET price = calcPrice(1);
			/* Uncomment for 10c och 10d */ 
			/* SELECT SLEEP(5) */
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

	SELECT (40 - COUNT(ticket_number)) INTO f_seats FROM Ticket
		INNER JOIN Reservation ON
		Reservation.reservation_number = Ticket.reservation_number
		INNER JOIN Flight Fl ON
		Fl.flight_number = Reservation.flight_number
		WHERE Fl.flight_number = flight_number;

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

	return ROUND(r_price * d_factor * (booked_seats + 1) / 40 * p_factor, 3);

END
//

CREATE TRIGGER createTickets AFTER INSERT ON Booking
	FOR EACH ROW
	BEGIN
		declare no_tickets INT;
		SELECT COUNT(passport_number) INTO no_tickets FROM Has_reservation AS H WHERE
			H.reservation_number = NEW.reservation_number;

		/* FLOOR(100000 + (RAND() * (999999 - 100000))) Creates a random number between 100 000 and 999 999,
		 	as the ticket number. */
		INSERT INTO Ticket
			SELECT FLOOR(100000 + (RAND() * (999999 - 100000))), passport_number , NEW.reservation_number FROM
				Has_reservation AS H WHERE H.reservation_number = NEW.reservation_number;
	END
//

delimiter ;

CREATE VIEW allFlights AS 
	SELECT 
		Dep.name AS departure_city_name,
		Arr.name AS destination_city_name,
		Ws.departure_time AS departure_time,
		Ws.weekday AS departure_day,
		F.week AS departure_week,
		R.year AS departure_year,
		calcFreeSeats(F.flight_number) AS nr_of_free_seats,
		calcPrice(F.flight_number) AS current_price_per_seat

	FROM Route AS R
		INNER JOIN Airport AS Dep ON R.departure = Dep.airport_code		
		INNER JOIN Airport AS Arr ON R.arrival = Arr.airport_code
		INNER JOIN Weekly_schedule AS Ws ON R.route_id = Ws.route
		INNER JOIN Flight AS F ON Ws.id = F.schedule;
	


/*  ----------------------------------------------------------------
# Answers to questions Lab4 part C

## Question 3: 

### Confirm that there is 208 Flights in the DB
SELECT Count(*) FROM Flight;

Execute:
> SELECT COUNT(*) FROM Flight

+ ------------- +
| COUNT(*)      |
+ ------------- +
| 208           |
+ ------------- +
1 rows


## Question 6:

### Confirm that the reservation is actually deleted upon overbooking:
SELECT * FROM Reservation WHERE reservation_number = @a;

Execute:
> SELECT * FROM Reservation WHERE reservation_number = @a

+ ----------------------- + ------------ + ------------------ + ------------------------- +
| reservation_number      | contact      | flight_number      | number_of_passengers      |
+ ----------------------- + ------------ + ------------------ + ------------------------- +
| NULL                    | NULL         | NULL               | NULL                      |
+ ----------------------- + ------------ + ------------------ + ------------------------- +
1 rows


## Question 7:

### Confirm that the test is correct, confirm that there is no output
There is no output.


## Question 8:

### a)

The credit card information should not be stored in plain text. Instead it should be encrypted with a suitable algorithm, like hashing the information about the credit card. So if a hacker is able to steal information in the database it would not be readable without first being decrypted.

### b)

- If the database is used in multiple applications, the procedures need to be written/copied for each of the applications. If some changes are done to the DB or the procedures, you would need to update in all those places. But by using stored procedures, it would only be needed changing in the backend system.

- By writing the functions in stored procedures you don't expose your database schema to the front end. This means that your database schema is unknown for the front end. The front end only knows how to call the procedures and use the backend through those.

- The performance in better, since all the calls to different tables and other functions is been done on the backend side, only the input parameters and result is sent over the network instead of all the different calls and parts of the procedures.

## Question 9:

### a)

OK

### b)

No, since the Transaction is not ended with a COMMIT or a ROLLBACK, the changes are not actually applied yet to the database.

### c)

When a modification is beeing done in B, it waits before actually doing the modification. Because A is currently modyfing that reservation whe are trying to modify from B, the specific reservation has a Read/Write lock until A commits to the database.

## Question 10:

### a)

No overbooking occured. Because upon payment the payment function checks if there are enough available seats to complete the booking. And since one of the session is first to do the payment, there are not enough seats left for the second one.

### b)

An overbooking can occur if our IF-statement:


IF(calcFreeSeats(flight_number) < (SELECT COUNT(passport_number) FROM Has_reservation AS Hr WHERE Hr.reservation_number = reservation_nr))


fails for both session. This can happen if there is some kind of delay after the IF-statement and the INSERT into the Bookings.

### c)

If we put the SELECT SLEEP(5) after our IF-statement that checks the available seats like below:


IF(calcFreeSeats(f_number) < (SELECT COUNT(passport_number) FROM Has_reservation AS Hr WHERE Hr.reservation_number = reservation_nr))THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There are not enough seats available on the flight anymore, deleting reservation";
	DELETE FROM Reservation WHERE reservation_number = reservation_nr;
ELSE
	SET price = calcPrice(1);
	SELECT SLEEP(5);
	INSERT INTO Booking VALUES (reservation_nr, cardholder_name, credit_card_number, price);
END IF;


both sessions passes the IF (calcFreeSeats(f_number)) since none of the sessions has managed to complete the booking.

### d) We lock all the tables used in the procedure addPayment to make sure that overbookings are not possible. This means that only one payment can be done at the time. Other payments must wait on the current payment to finish before they can access the necessary tables. By locking the tables in this way we make sure that tickets for a flight is generated and updated before other payments try to check if there is available seats on a flight.


	LOCK TABLES
		Booking read,
		Booking B write,
		Contact read,
		Ticket write,
		Flight F read,
		Flight read,
		Flight Fl read,
		Passenger P read,
		Reservation R read,
		Reservation write,
		Has_reservation Hr read,
		Route read,
		Weekday read,
		Weekly_schedule read,
		Year read;

	CALL addPayment (@a, "Sauron",7878787878);
	UNLOCK TABLES;


## Secondary index

In our table Ticket, we use the Ticket number as primary key, which makes it fast to search for a specific ticket. However if you would want to count the number of tickets for a specific reservation, we need to search for a reservation in the table Ticket. Since reservation_number is not indexed in the Ticket table, a linear would be needed which takes in average n / 2.

If we create a secondary index for the reservation_number, we can use binary search algorithm to access a specific record by the reservation_number.

Example: Let say we have 500 000 tickets in our Ticket table. Each ticket consists of attributes of the type INT. An INT is of size 4 byte. Let us assume one block is of size 2048 bytes.

One row in ticket consists of 3 attributes of 4 Byte each -> One row = 12 byte.

If we have 500 000 row -> 500 000 / 12 byte = 6 000 000 Byte of data.

One block is of size 3000 bytes -> Blocking factor = 2048 / 12 = 170.666 = 171 rows / block
Blocks needed to store the 500 000 rows = 500 000 / 171 = 2924 (rounded up from 2923.98)

Space wasted per block = 2048 - 170 / 12 = 8 Bytes

With our unmodified Database, if we would search for tickets with a specific reservation number, the average lookup time would be n / 2
where n is the number of blocks for the records -> 2924 / 2 = 1462 access of blocks.

With the modified DB with reservation number as a secondary index in the Ticket table, binary search algortihm can be used:
A block pointer is usually 4 or 6 bytes depending on the size of the stored data. Lets assume a block pointer is 4 bytes in this case.
This would mean the size of one index row = 4 + 4 = 8 Bytes for the reservation number and the pointer.

This gives the blocking factor of 2048 / 8 = 256 rows / block

No space wasted.
Blocks needed to store the 500 000 rows = 500 000 / 256 = 1954 (rounded up from 1953.13)

Search for a specific reservation number in the index with a binary search is log(n), where n is the number of blocks.
This gives us log(1954) = 3.29 block access on average. This is a great improvement when it come to the look up time.

This would greatly improve the efficiency when we look up the number of available seats for a flight for example.


 */