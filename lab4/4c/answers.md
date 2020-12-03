# Answers to questions Lab4 part C

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

```SQL
IF(calcFreeSeats(flight_number) < (SELECT COUNT(passport_number) FROM Has_reservation AS Hr WHERE Hr.reservation_number = reservation_nr))
```

fails for both session. This can happen if there is some kind of delay after the IF-statement and the INSERT into the Bookings.

### c)

If we put the SELECT SLEEP(5) after our IF-statement that checks the available seats like below:

```SQL
IF(calcFreeSeats(f_number) < (SELECT COUNT(passport_number) FROM Has_reservation AS Hr WHERE Hr.reservation_number = reservation_nr))THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "There are not enough seats available on the flight anymore, deleting reservation";
	DELETE FROM Reservation WHERE reservation_number = reservation_nr;
ELSE
	SET price = calcPrice(1);
	SELECT SLEEP(5);
	INSERT INTO Booking VALUES (reservation_nr, cardholder_name, credit_card_number, price);
END IF;
```

both sessions passes the IF (calcFreeSeats(f_number)) since none of the sessions has managed to complete the booking.

### d) Modify the testscripts so that overbookings are no longer possible using

<!-- (some of) the commands START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK
TABLES, ROLLBACK, SAVEPOINT, and SELECT…FOR UPDATE. Motivate why your
solution solves the issue, and test that this also is the case using the sleep
implemented in 10c. Note that it is not ok that one of the sessions ends up in a
deadlock scenario. Also, try to hold locks on the common resources for as
short time as possible to allow multiple sessions to be active at the same time. -->
