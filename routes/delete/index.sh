deleteRoom() {
   add_response_header "Content-Type" "application/json"
   parseParam '^/api/room/(.?)'
   sql="select * from room where id=$param; delete from room where id=$param;"
   results=$(sqlite3 database.db "$sql")
   json_results=$(echo "$results" | jq -Rs 'split("\n") | map(split("|") | {id: .[0], name: .[1], capacity: .[2]}) | .[:-1]')
   send_response_ok_exit <<< "$json_results"
}

on_uri_method_match '^/api/room/(.?)' "DELETE" deleteRoom
