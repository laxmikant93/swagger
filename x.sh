#!/bin/bash
CURRENT_DIR=$(pwd)/apps
YML_PATHS=$(find $CURRENT_DIR -regextype posix-egrep -regex "(.*)\.yml")
for ABS_PATH in $YML_PATHS; do
  RELATIVE_PATH=$(echo $ABS_PATH | sed -e "s/$(echo $CURRENT_DIR | sed 's/\//\\\//g')//g")
  FOLDER_NAME=$(echo $RELATIVE_PATH | awk -F "/" '{print $2}')
  APP_NAME=$(echo "$FOLDER_NAME" | awk '{ print $1 }' | sed "s/\-/./g")
  echo "-----adding $APP_NAME swagger docs-----"
  python3 scripts/main.py < $ABS_PATH >> $FOLDER_NAME.html
  sed -i '/<title>/ a <link rel="shortcut icon" type="image\/x-icon" href="https:\/\/'$APP_NAME'\/images\/favicon.ico">' $FOLDER_NAME.html
  APP
  sed -i 's/<title>Swagger UI/<title>Api Documentation - '$APP_NAME'/g' $FOLDER_NAME.html
  aws s3 cp $FOLDER_NAME.html s3://500apps-sites-dev/$FOLDER_NAME/developers/api-swagger.html --dryrun
done 