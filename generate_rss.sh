output_file="docs/xkcd_feed.xml"
merged_json="json/merged.json"

cat <<EOF >$output_file
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
   <channel>
      <title>[xkcd] Full Comic Feed</title>
      <link>https://xkcd.com/</link>
      <description>A feed of all xkcd comics.</description>
      <language>en-us</language>
      <copyright>xkcd.com</copyright>
      <lastBuildDate>{formatted_pub_date}</lastBuildDate>
      <atom:link href="https://tucker87.github.io/xkcd-rss/docs/xkcd_feed.xml" rel="self" type="application/rss+xml" />
EOF

jq -r '
  def pad2: if length == 1 then "0"+. else . end;

  def pub_date:
    (
      "\(.year)-\(.month|tostring|pad2)-\(.day|tostring|pad2)"
      | strptime("%Y-%m-%d")
      | mktime
      | strftime("%a, %d %b %Y %H:%M:%S GMT")
    );

  .[] |
  "      <item>
  <title>\(.title | sub("&"; "&amp;"; "g") | sub("<"; "&lt;"; "g") | sub(">"; "&gt;"; "g"))</title>
         <link>https://xkcd.com/\(.num)/</link>
         <description>
         <![CDATA[
            <div>
               <p>[<a href=\"https://xkcd.com/\(.num)/\">#\(.num)</a>] \(.alt)</p>
               <a href=\"\(.img)\">
                  <img src=\"\(.img)\" alt=\"\(.alt)\" style=\"height: auto\" />
               </a>
            </div>
         ]]>
         </description>
         <guid isPermaLink=\"true\">https://xkcd.com/\(.num)/</guid>
         <pubDate>\(pub_date)</pubDate>
      </item>"
' $merged_json >>$output_file

cat <<EOF >>$output_file
   </channel>
</rss>
EOF

xmllint --noout $output_file
