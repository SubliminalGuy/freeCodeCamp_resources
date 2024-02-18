#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c" 
NOT_FOUND() {
  echo "I could not find that element in the database."
  exit
}

if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$1
    # search for atomic_number
    ELEMENT_DATA=$($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM
elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number= $ATOMIC_NUMBER;")
    if [[ -z $ELEMENT_DATA ]]
    then
      NOT_FOUND
    else
      IFS='|' read -r NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT_DATA"
    fi
  elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]
  then 
    SYMBOL=$1
    # search for symbol
    ELEMENT_DATA=$($PSQL "SELECT name, atomic_number, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM
elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol= '$SYMBOL';")
    if [[ -z $ELEMENT_DATA ]]
    then
      NOT_FOUND
    else
      IFS='|' read -r NAME ATOMIC_NUMBER TYPE MASS MELTING BOILING <<< "$ELEMENT_DATA"
    fi
  else
    NAME=$1
    # search for name
    ELEMENT_DATA=$($PSQL "SELECT symbol, atomic_number, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM
elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name= '$NAME';")
    if [[ -z $ELEMENT_DATA ]]
    then
      NOT_FOUND
    else
      IFS='|' read -r SYMBOL ATOMIC_NUMBER TYPE MASS MELTING BOILING <<< "$ELEMENT_DATA"
    fi
  fi
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
else
  echo "Please provide an element as an argument." 
fi

