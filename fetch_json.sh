function get_json() {
	curl -sSf "https://xkcd.com/$1/info.0.json" >"json/$1-info.0.json"
}

count=${1:-10}
start=$(find json/* -printf "%f\n" | sort -n | tail -1 | sed 's/[^0-9]//g' | sed 's/.$//')
end=$((start + count))
i=$start
while [ "$i" -lt $end ]; do
	((i += 1))
	echo "Fetching $i | $((i - start)) / $count"
	get_json "$i" || exit
done
