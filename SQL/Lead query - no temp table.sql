WITH search_urls AS 
(
SELECT value 
    FROM table(split_to_table('search.aol.com,nortonsafe.search.ask.com,search.tb.ask.com,ask.com,aiqicha.baidu.com,b2b.baidu.com,bing.com,cn.bing.com,www2.bing.com,www4.bing.com,duckduckgo.com,next.duckduckgo.com,ecosia.org,google.com,ipv6.google.com,ipv4.google.com,search.naver.com,search.yahoo.com,images.search.yahoo.com,video.search.yahoo.com,mx.search.yahoo.com,espanol.search.yahoo.com,es.search.yahoo.com,mx.images.search.yahoo.com,espanol.images.search.yahoo.com,us.search.yahoo.com,es.images.search.yahoo.com,uk.search.yahoo.com,id.search.yahoo.com,tw.search.yahoo.com,mx.video.search.yahoo.com,hk.search.yahoo.com,espanol.video.search.yahoo.com,ca.search.yahoo.com,co.search.yahoo.com,es.video.search.yahoo.com,sg.search.yahoo.com,sg.video.search.yahoo.com,courant.search.yahoo.com,in.search.yahoo.com,ca.video.search.yahoo.com,co.images.search.yahoo.com,de.search.yahoo.com,id.images.search.yahoo.com,yandex.com', ','))
) /*this list of subdomains could be optimized, expanded and corrected when working WITHin a more flexible timeframe*/


,clickstream_ctr_prep AS
(
SELECT s.*,
       LEAD(s.created_time) OVER (PARTITION BY s.user_id ORDER BY s.created_time ASC) AS next_time,
       LEAD(s.subdomain) OVER (PARTITION BY s.user_id ORDER BY s.created_time ASC) AS next_subdomain,
       LEAD(s.domain_label) OVER (PARTITION BY s.user_id ORDER BY s.created_time ASC) AS next_domain_label,
       LEAD(s.query) OVER (PARTITION BY s.user_id ORDER BY s.created_time ASC) AS next_query,
       LEAD(s.is_serp) OVER (PARTITION BY s.user_id ORDER BY s.created_time ASC) AS next_is_serp,
       LEAD(s.referrer_url) OVER (PARTITION BY s.user_id ORDER BY s.created_time ASC) AS next_referrer_url
FROM
(
    SELECT cs.user_id,
           cs.created_time,
           cs.domain_label,
           cs.subdomain,
           CASE WHEN cs.subdomain IN (SELECT * FROM search_urls) THEN 1 ELSE 0 END AS is_serp,
           cs.url,
           cs.query,
           cs.referrer_url
    FROM assignment_click_stream cs
    --WHERE cs.created_time >= to_date('2023-04-30')
) s;
)


,clicks AS (
    SELECT click_type,
           COUNT(DISTINCT created_time||user_id) AS click_count
    FROM (
        SELECT CASE
                   WHEN ccp.next_referrer_url LIKE '%ad%' THEN 'ad click'
                   WHEN ccp.next_is_serp = 0 THEN 'organic click'
                   WHEN ccp.next_is_serp = 1 
                        AND ccp.domain_label = ccp.next_domain_label
                        AND ccp.query != ccp.next_query AND ccp.next_query IS NOT NULL THEN 'keyword change'
                   WHEN ccp.next_is_serp = 1 
                        AND ccp.domain_label = ccp.next_domain_label THEN 'stayed in search engine'
                   ELSE 'irrelevant'
                END AS click_type,
               ccp.* 
        FROM CLICKSTREAM_CTR_PREP ccp
        WHERE TIMESTAMPDIFF('second', ccp.created_time, ccp.next_time) <= 120
          AND ccp.is_serp = 1
    ) clicks
    GROUP BY click_type
)

SELECT *
FROM clicks;