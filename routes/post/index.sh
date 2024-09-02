createRoom() {
   add_response_header "Content-Type" "application/json"
   processBody
   name=$(echo $REQUEST_BODY | jq -r '.name')
   capacity=$(echo $REQUEST_BODY | jq -r '.capacity')
   sql="insert into room (name, capacity) values ('$name',$capacity); select * from room where id=last_insert_rowid();"
   results=$(sqlite3 database.db "$sql")
   json_results=$(echo "$results" | jq -Rs 'split("\n") | map(split("|") | {id: .[0], name: .[1], capacity: .[2]}) | .[:-1]')
   send_response_ok_exit <<< "$json_results"
}

on_uri_method_match '^/api/room' "POST" createRoom