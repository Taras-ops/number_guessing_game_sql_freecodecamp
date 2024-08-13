#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

GAME() {
  RANDOM_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
  USER_LAST_NUMBER=0
  COUNT=0
  
  echo "Guess the secret number between 1 and 1000:"

  while [[ $USER_LAST_NUMBER != $RANDOM_NUMBER ]]
  do
    read NUMBER
    
    if [[ ! $NUMBER =~ [0-9]+ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $NUMBER < $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $NUMBER > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi

    ((COUNT++))
    USER_LAST_NUMBER=$NUMBER
  done

  echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

  CURRENT_USER=$($PSQL "SELECT * FROM users WHERE name='$1'")

  echo $CURRENT_USER | while read ID BAR NAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      TOTAL_GAMES_PLAYED=$(($GAMES_PLAYED + 1))

      if [[ $COUNT < $BEST_GAME ]] || [[ $BEST_GAME == 0 ]]
      then
        RESULT=$($PSQL "UPDATE users SET best_game=$COUNT, games_played=$TOTAL_GAMES_PLAYED WHERE name='$1'")
      else
        RESULT=$($PSQL "UPDATE users SET games_played=$TOTAL_GAMES_PLAYED WHERE name='$1'")
      fi
    done 
}

MAIN_MENU() {
  echo "Enter your username:"
  read USERNAME

  CURRENT_USER=$($PSQL "SELECT * FROM users WHERE name='$USERNAME'")

  if [[ -z $CURRENT_USER ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    NEW_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")

    GAME $USERNAME
  else
    echo $CURRENT_USER | while read ID BAR NAME BAR GAMES_PLAYED BAR BEST_GAME
    do
      echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done 

    GAME $USERNAME
  fi
}

MAIN_MENU