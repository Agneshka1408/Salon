#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi 

AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services WHERE available = true ORDER BY service_id")
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME Service"
    done

echo -e "\nWhich one would you like to select?"
  read SERVICE_ID_SELECTED

     # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid services number."
    else
      # get bike availability

NAME_SERVICES=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED AND available = true")
      # if not available
      if [[ -z $NAME_SERVICES ]]
      then
        # send to main menu
        MAIN_MENU "I could not find that service. What would you like today?"
      else
REGISTERATION_MENU "$SERVICE_ID_SELECTED" "$NAME_SERVICES"
    fi
  fi  
}



REGISTERATION_MENU (){
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME=$2
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
       # insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")       
        fi


  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        echo -e "\nWhat time would you like your $($NAME_SERVICES  , $CUSTOMER_NAME | sed -E 's/^ +| +$//g')?"
        read SERVICE_TIME
        
  INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
       if [[ $INSERT_SERVICE_RESULT != "INSERT 0 1" ]]
       then 
MAIN_MENU "Could not schedule appointment, please schedule another service or try again later."
  else
    # Print success message
    echo -e "\nI have put you down for a $(echo $NAME_SERVICES at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"