# Answers to questions Lab4 part C

## Question 3:

### Confirm that there is 208 Flights in the DB

```sql
SELECT Count(*) FROM Flight;

Execute:

> SELECT COUNT(*) FROM Flight

- ------------- +
  | COUNT(*) |
- ------------- +
  | 208 |
- ------------- +
  1 rows
```

## Question 6:

### Confirm that the reservation is actually deleted upon overbooking:

```sql
SELECT * FROM Reservation WHERE reservation_number = @a;

Execute:

> SELECT * FROM Reservation WHERE reservation_number = @a

/* - ----------------------- + ------------ + ------------------ + ------------------------- +
  | reservation_number | contact | flight_number | number_of_passengers |
- ----------------------- + ------------ + ------------------ + ------------------------- +
  | NULL | NULL | NULL | NULL |
- ----------------------- + ------------ + ------------------ + ------------------------- +
  1 rows */

```

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

### d) We lock all the tables used in the procedure addPayment to make sure that overbookings are not possible. This means that only one payment can be done at the time. Other payments must wait on the current payment to finish before they can access the necessary tables. By locking the tables in this way we make sure that tickets for a flight is generated and updated before other payments try to check if there is available seats on a flight.

```SQL
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

```

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
