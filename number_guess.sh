#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
min=1
max=1000
RANDOM_NUMBER=$(($RANDOM%($max-$min+1)+$min))
NUMBER_GUESSES=0
echo -e "\n<<< Number Guessing Game >>>\n"

GUESS_LOOP() {
  if [[ $1 ]]
  then
    echo -e $1
  else
    echo "Guess the secret number between 1 and 1000:"
  fi
  read USER_GUESS
  if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_LOOP "That is not an integer, guess again:"
  else
    while  [[ $USER_GUESS != $RANDOM_NUMBER ]]
    do
      if [[ "$USER_GUESS" -gt "$RANDOM_NUMBER" ]]
      then
        ((NUMBER_GUESSES+=1))
        GUESS_LOOP "It's lower than that, guess again:"
      else [[ "$USER_GUESS" -lt "$RANDOM_NUMBER" ]]
        ((NUMBER_GUESSES+=1))
        GUESS_LOOP "It's higher than that, guess again:"
      fi
    done
    ((NUMBER_GUESSES+=1))
    CLOSE_FUNCTION
  fi

}

MAIN_FUNCTION() {
  echo "Enter your username:"
  read USERNAME
  USER_ID=$($PSQL "SELECT name, played_games, best_guess FROM users WHERE name='$USERNAME'")
  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    IFS='|' read -r NAME PLAYED_GAMES BEST_GUESS <<< "$USER_ID"
    echo "Welcome back, $NAME! You have played $PLAYED_GAMES games, and your best game took $BEST_GUESS guesses."
  fi

GUESS_LOOP
}



CLOSE_FUNCTION() {
  
  if [[ -z $PLAYED_GAMES ]]
  then
    PLAYED_GAMES=1
    CURRENT_GUESS=$NUMBER_GUESSES
    INSERT_USER_DATA=$($PSQL "INSERT INTO users(name,played_games,best_guess) VALUES('$USERNAME',1,$NUMBER_GUESSES);")
  else
    ((PLAYED_GAMES+=1))
    if [[ $BEST_GUESS -le $NUMBER_GUESSES ]]
    then
      BEST_GUESS=$BEST_GUESS
    else
      echo "Update Score"
      BEST_GUESS=$NUMBER_GUESSES
    fi
    INSERT_USER_DATA=$($PSQL "UPDATE users SET played_games = $PLAYED_GAMES,best_guess = $BEST_GUESS WHERE name = '$USERNAME';")
  fi
  echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  exit
}

MAIN_FUNCTION
