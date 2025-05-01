#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
  echo  test
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
  echo prod
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY"


cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # ให้ข้ามแถว header
 if [[ $YEAR != "year" ]]; then
  # ตรวจสอบ WINNER
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  
  if [[ -z $TEAM_ID ]]; then
    echo "No Team ID found for Winner: $WINNER. Inserting into teams table."
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
  else
    echo "Team ID: $TEAM_ID found for Winner: $WINNER."
  fi

  # ตรวจสอบ OPPONENT
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
  if [[ -z $TEAM_ID ]]; then
    echo "No Team ID found for Opponent: $OPPONENT. Inserting into teams table."
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
  else
    echo "Team ID: $TEAM_ID found for Opponent: $OPPONENT."
  fi

   # รับ team_id ทั้งสองฝ่าย
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # แทรกข้อมูลเกม
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) \
           VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"
fi
done
