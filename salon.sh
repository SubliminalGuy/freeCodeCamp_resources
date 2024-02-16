#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n" 
  fi
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    # send to main menu
    MAIN_MENU "Sorry, we don't have any services on offer now."
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
  # ask for bike to rent
    read SERVICE_ID_ENTERED
     # if input is not a number
    if [[ ! $SERVICE_ID_ENTERED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else
      # get service availability
      SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_ENTERED")
      # if not available
      echo $SERVICE_AVAILABILITY
      if [[ -z $SERVICE_AVAILABILITY ]]
      then
        # send to main menu
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read PHONE_NUMBER
        echo $PHONE_NUMBER
      fi
    fi
}
MAIN_MENU