/* I attempted an alternative approach by performing a self-join on the table, in order to have the clicks
 that occur WITHin a 2-minute span after the search alongside the search itself. However, this approach proved
  to be ineffective AS it resulted in the creation of a significantly larger table that is 
  unfeasible to query efficiently. */

CREATE OR REPLACE temporary TABLE CLICKSTREAM_CTR_PREP AS 
-- search engines according to https://blog.hubspot.com/marketing/top-search-engines
WITH search_urls AS 
(
SELECT value 
    FROM table(split_to_table('search.aol.com,nortonsafe.search.ask.com,search.tb.ask.com,ask.com,aiqicha.baidu.com,b2b.baidu.com,bing.com,cn.bing.com,www2.bing.com,www4.bing.com,duckduckgo.com,next.duckduckgo.com,ecosia.org,google.com,ipv6.google.com,ipv4.google.com,search.naver.com,search.yahoo.com,images.search.yahoo.com,video.search.yahoo.com,mx.search.yahoo.com,espanol.search.yahoo.com,es.search.yahoo.com,mx.images.search.yahoo.com,espanol.images.search.yahoo.com,us.search.yahoo.com,es.images.search.yahoo.com,uk.search.yahoo.com,id.search.yahoo.com,tw.search.yahoo.com,mx.video.search.yahoo.com,hk.search.yahoo.com,espanol.video.search.yahoo.com,ca.search.yahoo.com,co.search.yahoo.com,es.video.search.yahoo.com,sg.search.yahoo.com,sg.video.search.yahoo.com,courant.search.yahoo.com,in.search.yahoo.com,ca.video.search.yahoo.com,co.images.search.yahoo.com,de.search.yahoo.com,id.images.search.yahoo.com,yandex.com', ','))
) /*this list of subdomains could be optimized, expanded and corrected when working WITHin a more flexible timeframe*/

, WITHserp AS 
(
SELECT  cs.user_id
        ,cs.created_time
        ,cs.domain_label
        ,cs.subdomain
        ,CASE WHEN cs.subdomain IN (SELECT * FROM search_urls) THEN 1 ELSE 0 END AS is_serp
        ,cs.url
        ,cs.query
        
FROM assignment_click_stream cs
WHERE cs.created_time >= to_date('2023-04-30')  
)


SELECT s.user_id
      ,s.created_time
      ,s.url
      ,s.query
      ,s2.created_time next_time
      ,s2.url next_url
      ,s2.query next_query

FROM WITHserp s
JOIN WITHserp s2 
ON timestampdiff('second', s.created_time, s2.created_time) <= 120
AND s2.user_id = s.user_id
AND s.is_serp = 1

;
/* I performed a query for a specific user_id to find how many rows have been created, then I turned to the lead query after understanding it was impractical to continue with this direction*/
SELECT ccp.* 

FROM CLICKSTREAM_CTR_PREP ccp

WHERE USER_ID = 1108050081

ORDER BY CREATED_TIME