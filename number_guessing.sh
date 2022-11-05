#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESS_NUMBER=$(($RANDOM%1000+1))

echo $GUESS_NUMBER
echo "Enter your username:"
read USERNAME

PLAYER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $PLAYER ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

  if [[ $INSERT_USER == "INSERT 0 1" ]]
  then
    PLAYER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$PLAYER'")
    echo "Welcome, $PLAYER! It looks like this is your first time here."

  COUNT=0
  echo "Guess the secret number between 1 and 1000:"
  while read USER_GUESS
  do
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $USER_GUESS == $GUESS_NUMBER ]]
      then
        COUNT=$(($COUNT + 1))
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$PLAYER'")
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guess) VALUES($USER_ID, $COUNT)")
        echo "You guessed it in $COUNT tries. The secret number was $GUESS_NUMBER. Nice job!"
      break
      elif [[ $USER_GUESS < $GUESS_NUMBER ]]
      then
        COUNT=$(($COUNT + 1))
        echo "It's higher than that, guess again:"
      elif [[ $USER_GUESS > $GUESS_NUMBER ]]
      then 
        COUNT=$(($COUNT + 1))
        echo "It's lower than that, guess again:"
      fi
    fi
  done
  fi

elif [[ $PLAYER ]]
then
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$PLAYER'")
  GAME_COUNT=$($PSQL "SELECT COUNT(number_of_guess) FROM games WHERE user_id=$USER_ID")
  MIN_GUESS=$($PSQL "SELECT MIN(number_of_guess) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $PLAYER! You have played $GAME_COUNT games, and your best game took $MIN_GUESS guesses."
  echo "Guess the secret number between 1 and 1000:"
while read USER_GUESS
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    COUNT=$(($COUNT + 1))
    echo "That is not an integer, guess again:"
  else
    if [[ $USER_GUESS == $GUESS_NUMBER ]]
    then
      COUNT=$(($COUNT + 1))
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$PLAYER'")
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guess) VALUES($USER_ID, $COUNT)")
      echo "You guessed it in $COUNT tries. The secret number was $GUESS_NUMBER. Nice job!"
      break
    elif [[ $USER_GUESS < $GUESS_NUMBER ]]
    then
      COUNT=$(($COUNT + 1))
      echo "It's higher than that, guess again:"
    elif [[ $USER_GUESS > $GUESS_NUMBER ]]
    then 
      COUNT=$(($COUNT + 1))
      echo "It's lower than that, guess again:"
    fi
  fi
done
fi
