

-- This query calculates the click COUNT per subdomain for the top search engines based on the list provided by https://blog.hubspot.com/marketing/top-search-engines.
-- The final result set includes the subdomain RANK WITHin each domain label.

WITH clicks_per_subdomain AS
(
SELECT COUNT(cs.created_time) click_count
                ,subdomain
                ,domain_label
                
FROM assignment_click_stream cs
WHERE cs.domain_label IN ('google',
                          'bing',
                          'yahoo',
                          'yandex',
                          'duckduckgo',
                          'baidu',
                          'ask',
                          'naver',
                          'ecosia',
                          'aol')
and cs.url LIKE ANY ('%google.com/search?q%', '%bing.com/search?q%', '%search.yahoo.com/search%', '%yandex.com/search/?%', '%duckduckgo.com/?q%',  '%baidu.com/s?%', '%ask.com/web?q%', '%search.naver.com/search.naver?%', '%ecosia.org/search?%', '%search.aol.com/aol/search?q%')
 AND cs.query IS NOT NULL

 GROUP BY cs.subdomain, cs.domain_label
 )

SELECT cps.*
       ,RANK() over (PARTITION BY cps.domain_label ORDER BY cps.click_count DESC) subdomain_rank

FROM clicks_per_subdomain cps
