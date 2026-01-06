merged_json="episodes.json"

function get_json() {
	json=$(curl -sSf "https://xkcd.com/$1/info.0.json") || return 2
	merged=$(cat "$merged_json")
	echo "$merged" | jq --argjson new "$json" '. + [$new]' >"$merged_json"
}

count=${1:-10}
start=$(jq '.[-1].num' "$merged_json")
end=$((start + count))
i=$start
while [ "$i" -lt $end ]; do
	((i += 1))
	echo "Fetching $i | $((i - start)) / $count"
	get_json "$i" || { [ $? -eq 2 ] && exit 0 || exit 1; }

done
