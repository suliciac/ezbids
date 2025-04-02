#!/bin/bash

FOLDER=$1
SESSION=$2

API_URL="http://localhost:8082"
UI_URL="http://localhost:3000/ezbids/convert"


if [ ! -z "$FOLDER" ]; then
    cd $FOLDER
fi

if [ -z "$SESSION" ]; then
    SESSION=$(
        curl "$API_URL/session" \
            -X "POST" \
            -H "Content-Type: application/json" | jq -r '._id'
    )
    # DEBUG line 
    echo "DEBUG: Session ID is '$SESSION'"
fi


echo ""
echo "Session ID: $SESSION"
echo ""


FOLDER_NAME=$(basename `pwd`)

echo "Uploading `pwd`"
#for file in $(find * -type f); do
find * -type f | while IFS= read -r file; do
    echo "Uploading $file"
    curl "$API_URL/upload-multi/$SESSION" \
        -H "Authorization: Bearer ${bearerToken}" \
        -F "paths=$FOLDER_NAME/$file" \
        -F "mtimes=1706756151" \
        -F "files=@$file"
    echo
done


echo "Marking as done"
curl "$API_URL/session/uploaded/$SESSION" \
  -X 'PATCH'

echo ""
echo "$UI_URL/#$SESSION"
