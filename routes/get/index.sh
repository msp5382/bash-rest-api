listRoom() {
   add_response_header "Content-Type" "application/json"
   results=$(sqlite3 database.db "select * from room;")
   if [ -z "$results" ] 
   then
      send_response_ok_exit <<< "[]"
   fi
   json_results=$(echo "$results" | jq -Rs 'split("\n") | map(split("|") | {id: .[0], name: .[1], capacity: .[2]}) | .[:-1]')
   send_response_ok_exit <<< "$json_results"
}

on_uri_method_match '^/api/room' "GET" listRoom