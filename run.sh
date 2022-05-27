#!/bin/bash

api_header="x-api-key: default-hvs-api-key"
root_url="localhost:4000/api"

CHECK=$(curl -s "$root_url/check" -H "$api_header")

if [[ $CHECK != "API accessible" ]]; then
	echo "API not accessible... is the server running at 'localhost:4000'?"
	exit 1
fi

case $1 in

	create_user)
		body="{\"first_name\":\""$2"\", \"last_name\":\""$3"\", \"email\":\""$4"\"}"
		curl -s "$root_url/users" -X POST -H "$api_header" -H "Content-Type: application/json" -d "$body"
	;;

	user_list)
		curl -s "$root_url/users" -H "$api_header"
	;;

	request_visit)
		body="{\"member\":\""$2"\", \"date\":\""$3"\", \"minutes\":\""$4"\", \"tasks\":\""$5"\"}"
		curl -s "$root_url/users/$2/request" -X POST -H "$api_header" -H "Content-Type: application/json" -d "$body"
	;;

	visit_list)
		curl -s "$root_url/visits" -H "$api_header"
	;;

	fulfill_visit)
		body="{\"pal_id\":\""$3"\"}"
		curl -s "$root_url/visits/$2/fulfill" -X POST -H "$api_header" -H "Content-Type: application/json" -d "$body"
	;;

	*)
		echo "Missing directive"
	;;

esac
