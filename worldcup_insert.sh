#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n~~~ Filling the Worldcup Database ~~~\n"
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != winner ]]
  then
    # get winner_team_id
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
        WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        #echo $WINNER_TEAM_ID
      fi  
    fi
  fi
    # get opponent_team_id
    
  if [[ $OPPONENT != opponent ]]
    then
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      # if not found
      if [[ -z $OPPONENT_TEAM_ID ]]
      then
        # insert opponent
        INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted into teams, $OPPONENT
          OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
          #echo $OPPONENT_TEAM_ID
        fi  
      fi
  fi
  if [[ $YEAR != year ]]
  then
    # insert YEAR, ROUND,WINNER, OPPONENT, WINNER GOALS AND OPP_GOALS in games
    INSERT_GAME_DATA_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR','$ROUND', '$WINNER_TEAM_ID', '$OPPONENT_TEAM_ID','$WINNER_GOALS','$OPPONENT_GOALS')")
    echo $INSERT_GAME_DATA_RESULT
    #TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if not found
  fi

done