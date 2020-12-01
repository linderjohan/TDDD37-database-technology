
/* Year test */
INSERT INTO Year VALUES (2011, 2.1), (2012, 2.9);

SELECT * FROM Year;

DELETE FROM Airport;
INSERT INTO Airport VALUES 
	("JOC", "Jock TOWN", "JOCKLAND"), 
	("MOC", "MOck town", "Mockland"),
	("TOC", "TOck town", "Tockland");



SELECT * FROM Airport;

INSERT INTO Route (departure, arrival, year, price) VALUES
	("JOC", "MOC", 2012, 2000),
	("JOC", "TOC", 2011, 1999);


INSERT INTO Route (departure, arrival, year, price) VALUES ("JOC", "TOC", 2011, 1999);

SELECT * FROM Route;

SELECT country FROM Airport
INNER JOIN Route ON Airport.airport_code = Route.departure;

INSERT INTO Weekday VALUES ("Måndag", 2012, 12.1), ("Tisdag", 2011, 12.3);	



INSERT INTO Weekly_schedule (route, weekday, year, departure_time) VALUES
	(1, "Tisdag", 2011, "12:00:00");
    
    
    
	SELECT price FROM Route
		INNER JOIN Weekly_schedule ON
		Weekly_schedule.route = Route.route_id
		INNER JOIN Flight ON
		Flight.schedule = Weekly_schedule.id
		WHERE Flight.flight_number = 80;
        
        
			SELECT weekday_factor FROM Weekday
			INNER JOIN Weekly_schedule ON
			(Weekly_schedule.weekday = Weekday.day AND
			Weekly_schedule.year = Weekday.year)
			INNER JOIN Flight ON
			Flight.schedule = Weekly_schedule.id
			WHERE Flight.flight_number = 80;
            
            
            
            	SELECT profit_factor FROM Year
		INNER JOIN Weekly_schedule ON
		Weekly_schedule.year = Year.year
		INNER JOIN Flight ON
		Flight.schedule = Weekly_schedule.id
		WHERE Flight.flight_number = 80;
        
        
		SELECT (40 - COUNT(number_of_passengers)) FROM Reservation
		INNER JOIN Payment ON
		Payment.reservation_number = Reservation.reservation_number
		INNER JOIN Flight ON
		Flight.schedule = Reservation.flight_number
		WHERE Flight.flight_number = 82;
        
        DROP PROCEDURE calcPrice;
        delimiter //
        
        CREATE PROCEDURE calcPrice(IN flight_number INT, OUT test DOUBLE ) 
BEGIN
	declare r_price DOUBLE;
	declare d_factor DOUBLE;
	declare p_factor DOUBLE;
	declare booked_seats INT;
	/* set booked_seats = 40 - calcFreeSeats(flight_number); */
	set booked_seats = 39;

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

	/*return r_price * d_factor * (booked_seats + 1) / 40 * p_factor;*/
	set test = r_price * d_factor * ((booked_seats + 1) / 40) * p_factor;

END
//

delimiter ;
CALL calcPrice(80, @a);
SELECT @a;
        