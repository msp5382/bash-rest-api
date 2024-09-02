#!/usr/bin/env bash

send() {
        printf '%s\r\n' "$*";
 }

DATE=$(date +"%a, %d %b %Y %H:%M:%S %Z")
declare -a RESPONSE_HEADERS=(
	"Date: $DATE"
	"Expires: $DATE"
	"Server: Bash REST Server"
)

add_response_header() {
	RESPONSE_HEADERS+=("$1: $2")
}

declare -a HTTP_RESPONSE=(
	[200]="OK"
	[400]="Bad Request"
	[403]="Forbidden"
	[404]="Not Found"
	[405]="Method Not Allowed"
	[500]="Internal Server Error"
)

send_response() {
	local code=$1
   	send "HTTP/1.0 $1 ${HTTP_RESPONSE[$1]}"
   	for i in "${RESPONSE_HEADERS[@]}"; do
   		send "$i"
   	done
   	send
   	while read -r line; do
   		send "$line"
   	done
}

send_response_ok_exit() { send_response 200; exit 0; }

fail_with() {
	send_response "$1" <<< "$1 ${HTTP_RESPONSE[$1]}"
	exit 1
}

on_uri_match() {
	local regex=$1
	shift
	[[ $REQUEST_URI =~ $regex ]] && "$@" "${BASH_REMATCH[@]}"
}

on_uri_method_match() {
	local regex=$1
	local method=$2
	shift 2
	[[ $REQUEST_URI =~ $regex ]] && [ "$REQUEST_METHOD" = "$method" ] && "$@" "${BASH_REMATCH[@]}"
}

parseParam() {
	local regex=$1
	[[ $REQUEST_URI =~ $regex ]] && param="${BASH_REMATCH[1]}"
}

processBody() {
    echo "About to read body" >&2
    echo $contentLength >&2
    REQUEST_BODY=""

    bodylen=0
    while IFS= read -r -n1 char; do
        REQUEST_BODY+="$char"
        ((bodylen+=1))
        [ $bodylen -eq $contentLength ] && break
    done
    echo "$REQUEST_BODY" >&2
}


processHeaders()
{
	
	read -r request || fail_with 400


	request=${request%%$'\r'}
	echo $request >&2
	read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION <<<$request

	[ -n "$REQUEST_METHOD" ] && \
	[ -n "$REQUEST_URI" ] && \
	[ -n "$REQUEST_HTTP_VERSION" ] \
	   	|| fail_with 400

	[ "$REQUEST_METHOD" = "GET" ] || [ "$REQUEST_METHOD" = "POST" ] || [ "$REQUEST_METHOD" = "PUT" ] || [ "$REQUEST_METHOD" = "DELETE" ] || fail_with 405

	declare -a REQUEST_HEADERS

	contentLength=0

	while read -r header; do
		header=${header%%$'\r'}
		[ -z "$header" ] && break
		echo $header >&2
		REQUEST_HEADERS+=("$header")
		if [[ $header =~ ^Content-Length:\ ([0-9]+)$ ]]; then
			contentLength=${BASH_REMATCH[1]}
		fi
	done

}
