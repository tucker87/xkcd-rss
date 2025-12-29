i=1
max=$(find json/* -printf "%f\n" | sort -n | tail -1 | sed 's/[^0-9]//g' | sed 's/.$//')
xml="xkcd_feed.xml"

cat <<EOF >$xml
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
   <channel>
      <title>[xkcd] Full Comic Feed</title>
      <link>https://xkcd.com/</link>
      <description>A feed of all xkcd comics.</description>
      <language>en-us</language>
      <copyright>xkcd.com</copyright>
      <lastBuildDate>{formatted_pub_date}</lastBuildDate>
      <atom:link href="https://tucker87.github.io/xkcd-rss/docs/rss/xkcd_feed.xml" rel="self" type="application/rss+xml" />
EOF
while [ "$i" -le "$max" ]; do
	if [[ $i -eq 404 ]]; then # Really funny XKCD. :P
		((i++))
		continue
	fi

	echo "Processing episode $i / $max"

	json=$(<json/$i-info.0.json)
	num=$(echo -E "$json" | jq -r '.num')
	title=$(echo -E "$json" | jq -r '.title')
	alt_text=$(echo -E "$json" | jq -r '.alt')
	img_url=$(echo -E "$json" | jq -r '.img')

	#Wed, 12 Feb 2020 00:00:00 GMT
	year=$(echo -E "$json" | jq -r '.year')
	month=$(echo -E "$json" | jq -r '.month')
	day=$(echo -E "$json" | jq -r '.day')

	formatted_pub_date=$(date -d "$year-$month-$day" +"%a, %d %b %Y %H:%M:%S GMT")

	cat <<EOF >>$xml
      <item>
         <title>$title</title>
         <link>https://xkcd.com/$num/</link>
         <description>
         <![CDATA[
            <div>
               <p>[<a href="https://xkcd.com/$num/">#$num</a>] $alt_text</p>
               <a href="$img_url">
                  <img src="$img_url" alt="$alt_text" style="height: auto" />
               </a>
            </div>
         ]]>
         </description>
         <guid isPermaLink="true">https://xkcd.com/$num/</guid>
         <pubDate>$formatted_pub_date</pubDate>
      </item>
EOF
	((i++))
done
cat <<EOF >>$xml
   </channel>
</rss>
EOF
