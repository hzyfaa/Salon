#! /bin/bash

echo -e "\n~~ Salon Shop ~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

function MAIN_MENU() {
if [[ -n "$1" ]]
  then echo -e "$1"
fi
SERVICES=$($PSQL "SELECT * FROM services ORDER BY SERVICE_ID")
#show list of options
echo "$SERVICES" | while read SERVICE_ID BAR SERVICE BAR
do 
  echo "$SERVICE_ID) $SERVICE"
done
#read choice
read SERVICE_ID_SELECTED

SERVICE_TYPE="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"

case "$SERVICE_ID_SELECTED" in
  1|2|3) BOOK_SERVICE "$SERVICE_TYPE";;
  *) MAIN_MENU "Invalid selection. Choose from the following:" ;;
esac
}

function BOOK_SERVICE() {

 # get phone number
 echo -e "\nWhat is your phone number?"
 read CUSTOMER_PHONE 

 # if number does not exist, ask for name 
 NAME_STORED="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
 if [[ -z $NAME_STORED ]] 
 then
  echo -e "\nWhat is your name?"
  read CUSTOMER_NAME

  # enter data into table
  INSERT_NEW_CUSTOMER="$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")"

 else

  CUSTOMER_NAME=$NAME_STORED

 fi 

 # get customer id 
 CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"

 #ask for time 
 echo -e "\nWhat time would you like to book your appointment, $(echo $CUSTOMER_NAME | sed 's/ //g')?"
 read SERVICE_TIME

 INSERT_APPOINTMENT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")"
 
 echo -e "\nI have put you down for a $(echo $1 | sed 's/ //g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //g')."

}

MAIN_MENU
