#!/bin/bash

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {

  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "1) Cut\n2) Color\n3) Perm\n4) Style\n5) Trim"
  
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1|2|3|4|5)
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      ;;
    *)
      MAIN_MENU "I could not find that service. What would you like today?"
      return
      ;;
  esac

  # Get customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  AVAILABLE_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Check if customer exists
  if [[ -z $AVAILABLE_PHONE ]]; then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    CREATE_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Create appointment
  CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")

  if [[ $CREATE_APPOINTMENT == "INSERT 0 1" ]]; then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nThere was an error booking your appointment. Please try again."
  fi
}

# Run main menu
MAIN_MENU
