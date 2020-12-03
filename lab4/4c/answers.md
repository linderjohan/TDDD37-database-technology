# Answers to questions Lab4 part C

## Question 8:

### a) How can you protect the credit card information in the database from hackers?

The credit card information should not be stored in plain text. Instead it should be encrypted with a suitable algorithm, like hashing the information about the credit card. So if a hacker is able to steal information in the database it would not be readable without first being decrypted.

### b) Give three advantages of using stored procedures in the database (and thereby execute them on the server) instead of writing the same functions in the frontend of the system (in for example java-script on a web-page)?

- If the database is used in multiple applications, the procedures need to be written/copied for each of the applications. If some changes are done to the DB or the procedures, you would need to update in all those places. But by using stored procedures, it would only be needed changing in the backend system.

- By writing the functions in stored procedures you don't expose your database schema to the front end. This means that your database schema is unknown for the front end. The front end only knows how to call the procedures and use the backend through those.

- The performance in better, since all the calls to different tables and other functions is been done on the backend side, only the input parameters and result is sent over the network instead of all the different calls and parts of the procedures.

https://www.ida.liu.se/local/students/mysql/passwd
