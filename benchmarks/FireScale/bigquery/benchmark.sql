-- SELECT HASH_AGG(*) FROM uservisits;

-- SELECT HASH_AGG(*) FROM rankings;

-- query 1
SELECT visitdate, sourceip, adrevenue 
FROM uservisits 
WHERE (visitdate BETWEEN '2022-04-10' AND '2022-04-24')
AND sourceip IN ('9.232.65.46')
AND countrycode = 'ISL';

-- query 2
with desktop as ( 
            select 
            date_trunc(visitdate, MONTH) as year_month_day,
            sourceip,
            countrycode, 
            count(*) as visits,
            sum(adrevenue) as adrevenue, 
            count(distinct languagecode)  as languagecode, 
            max(length(searchword)) as searchwordlength,
            sum(duration) as time_on_site
            from uservisits
            where sourceip in ('99.99.39.185')
            and countrycode < 'zzz'
            and visitdate between '2023-07-21' and '2023-07-26'
            and useragent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
            group by sourceip,countrycode,year_month_day), 
 mobile as (
            select 
             date_trunc(visitdate, MONTH) as year_month_day,
            sourceip,
            countrycode, 
            count(*) as visits,
            sum(adrevenue) as adrevenue, 
            count(distinct languagecode)  as languagecode, 
            max(length(searchword)) as searchwordlength,
            sum(duration) as time_on_site
            from uservisits
            where sourceip in ('1.0.100.18')
            and countrycode < 'zzz'
            and visitdate between '2023-07-21' and '2023-07-26'
            and useragent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 13 like Mac OS X) AppleWebKit/958 (KHTML, like Gecko) Version/25.55 Mobile/15E148 Safari/815'
            group by sourceip,countrycode,year_month_day)
select 
    COALESCE(desktop.year_month_day,mobile.year_month_day) as year_month_day,
    COALESCE(desktop.sourceip,mobile.sourceip) as site,
    COALESCE(desktop.countrycode,mobile.countrycode) as countrycode,
    COALESCE(desktop.visits,0) + COALESCE(mobile.visits,0) as visits,
    COALESCE(desktop.adrevenue,0)+ COALESCE(mobile.adrevenue,0) as page_views,
    COALESCE(desktop.searchwordlength,0) + COALESCE(mobile.searchwordlength,0) as searchwordlength,
    COALESCE(desktop.time_on_site,0) + COALESCE(mobile.time_on_site,0) as time_on_site
from desktop
full outer join mobile on 
mobile.year_month_day = desktop.year_month_day AND
mobile.sourceip = desktop.sourceip AND
mobile.countrycode = desktop.countrycode;

-- query 3
SELECT languagecode,
    MAX(visitdate) AS visitdate,
    ARRAY_TO_STRING(ARRAY_AGG(countrycode), ',') AS countrycode
FROM uservisits
WHERE sourceip = '61.57.9.153' and visitdate between '2023-07-03' and '2023-07-04'
GROUP BY languagecode;

-- query 4
SELECT *
FROM uservisits
WHERE sourceip = '95.184.141.191' and visitdate between '2022-08-03' and '2022-08-04';

-- query 5
WITH filtered_uservisits AS( SELECT *     
  FROM uservisits     
  WHERE visitdate between '2023-05-18' and '2023-05-19') 
  SELECT allowed_records.destinationurl, COUNT(*) OVER () as total_uservisits_count 
  FROM filtered_uservisits JOIN ( SELECT destinationurl 
                                FROM filtered_uservisits 
                                ORDER BY duration DESC LIMIT 100 ) AS allowed_records ON allowed_records.destinationurl = filtered_uservisits.destinationurl 
  ORDER BY adrevenue desc LIMIT 20 OFFSET 0;

-- query 6
SELECT COUNT(*) as c FROM uservisits WHERE sourceip = '199.207.100.14' and visitdate = '2022-11-21';

-- query 7
SELECT max(visitdate) as latest_visit
FROM uservisits
WHERE (visitdate >= '2021-03-24' AND visitdate <= date_add('2021-03-24', INTERVAL 1 DAY));

-- query 8
SELECT date_trunc(visitdate, MONTH) as year_month_day,
COALESCE(SUM(duration), 0) as installs,
COALESCE(SUM(length(searchword)), 0) as billingCost,
SUM(CASE WHEN adrevenue <= 1.5 THEN duration ELSE 0 END) as revenueD7
FROM uservisits
WHERE (visitdate >= '2022-10-06' AND visitdate <= date_add('2022-10-06', INTERVAL 1 DAY))
        AND languagecode IN ('CYP-EL', 'SGP-EN', 'BIH-SR', 'ROU-RO', 'CHL-ES', 'MKD-MK', 'ISR-IW')
GROUP BY 1
ORDER BY 1;

-- query 9
SELECT destinationurl
from uservisits
where adrevenue between 0.11934252957541426 and 0.29931052288731086 and visitdate between '2024-09-06' and '2024-09-12'
group by destinationurl having count(*) > 100;

-- query 10
with busiest_days as (
  select visitdate, count(*)
  from uservisits
  group by 1
  order by 2 desc
  limit 31
)
select countrycode, avg(length(searchword))
from uservisits
where visitdate in (select visitdate from busiest_days)
group by countrycode;

-- query 11
SELECT searchword, useragent, languagecode
from uservisits 
where countrycode = 'QAT'
  and visitdate = '2024-05-03' 
  and searchword in ('come firm', 'draw indicate', 'close guess', 'certain', 'design trip news', 'the these section')
Limit 65;

-- query 12
SELECT
  countrycode,
  languagecode,
  COUNT(DISTINCT visitdate) AS days_with_data,
  MAX(visitdate) last_visit,
  SUM(adrevenue) sum_adrevenue,
  MAX(adrevenue) max_adrevenue,
  COUNT(*) cnt
FROM
  uservisits
WHERE
  visitdate >= '2020-10-04' and visitdate <= '2020-11-03' AND
  countrycode in ('FRA', 'BHR', 'SGP', 'AUT', 'IRQ', 'NZL', 'DOM', 'LUX', 'NZL', 'CHE') AND
  languagecode in ('FRA-FR', 'BHR-AR', 'SGP-ZH', 'AUT-DE', 'IRQ-AR', 'NZL-EN', 'DOM-ES', 'LUX-FR', 'NZL-EN', 'CHE-IT') AND
  useragent in (
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)', 
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)', 
    'Mozilla/5.0 (iPhone; U; CPU like Mac OS X)AppleWebKit/420.1 (KHTML like Gecko) Version/3.0 Mobile/4A93Safari/419.3', 
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)', 
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)', 
    'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2)', 
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)', 
    'Opera 9.2 (Windows Vista): Opera/9.20 (Windows NT 6.0; U; en)', 
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/701 (KHTML, like Gecko) Chrome/74.60 Safari/771', 
    'Mozilla/5.0 (Macintosh; PPC Mac OS X; U; en)Opera 8.0'
  )
GROUP BY 1, 2;

-- query 13
WITH                 
                CTE1 AS 
                ( 
                    SELECT languagecode FROM uservisits
WHERE uservisits.countrycode = 'CHE'
  limit 1
                ),
                CTE2 AS 
                ( 
                    SELECT uservisits.languagecode, 
                    null AS topic, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) 
                    AS s1, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) 
                    AS s2, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) 
                    AS s3 
                    FROM uservisits

 INNER JOIN agents ON  uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-07-29' and '2024-08-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') AND uservisits.searchword IN ('itself total') 
                    AND agents.operatingsystem = 'Windows 10'
                    GROUP BY uservisits.languagecode
                ), CTE3 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, SUM(CASE WHEN agents.operatingsystem = 'Windows 10' 
                    AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS s1, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) 
                    AS s4, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS s2, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS s3 
                    FROM uservisits

 INNER JOIN agents ON  uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-07-29' and '2024-08-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') AND uservisits.searchword IN ('itself total') 
                    AND agents.operatingsystem = 'Windows 10'
                    GROUP BY uservisits.languagecode
                ), CTE4 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS s1, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS 
                    s5, SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS s2, 
                    SUM(CASE WHEN agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  THEN duration ELSE NULL END) AS s3 
                    FROM uservisits

 INNER JOIN agents ON  uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-07-29' and '2024-08-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND uservisits.searchword IN ('itself total') 
                    AND agents.operatingsystem = 'Windows 10'
                    GROUP BY uservisits.languagecode
                ), CTE5 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN languagecode ELSE NULL END)) AS s1, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN languagecode ELSE NULL END)) AS s5, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN languagecode ELSE NULL END)) AS s4 
                    FROM uservisits

 INNER JOIN agents ON  uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-07-29' and '2024-08-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.operatingsystem = 'Windows 10'
                    GROUP BY uservisits.languagecode
                ), CTE6 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN languagecode ELSE NULL END)) AS s3 
                    FROM uservisits
   INNER JOIN searchwords ON uservisits.searchword = searchwords.word
 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-09-29' and '2024-10-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') AND languagecode NOT IN ( SELECT * FROM CTE1 ) 
                    AND uservisits.sourceip IN ('123.143.30.99', '126.98.46.113') 
                    AND agents.operatingsystem = 'macOS'
                    GROUP BY uservisits.languagecode
                ), CTE7 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic,
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN 
                        CASE WHEN languagecode IS NOT NULL 
                        AND uservisits.sourceip <> '118.113.25.140' THEN languagecode ELSE NULL END END)) 
                        AS s6 
                    FROM uservisits

 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-12-29' and '2025-01-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.devicearch = 'ARM'
                    GROUP BY uservisits.languagecode
                ), CTE8 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname  
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname 
                        THEN 1 ELSE NULL END) THEN languagecode ELSE NULL END)) AS s6 
                    FROM uservisits

 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-12-29' and '2025-01-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.devicearch = 'x86'
                    GROUP BY uservisits.languagecode
                ), CTE9 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname 
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) 
                        THEN CASE WHEN languagecode IS NOT NULL 
                        AND uservisits.sourceip <> '118.113.25.140' THEN languagecode ELSE NULL END END)) AS s6 
                    FROM uservisits

 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-12-29' and '2025-01-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.devicearch = 'x86'
                    GROUP BY uservisits.languagecode
                ), CTE10 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname 
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname 
                        THEN 1 ELSE NULL END) THEN languagecode ELSE NULL END)) AS s6 
                    FROM uservisits

 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-12-29' and '2025-01-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.devicearch = 'ARM'
                    GROUP BY uservisits.languagecode
                ), CTE11 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname 
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN 
                        CASE WHEN languagecode IS NOT NULL 
                        AND uservisits.sourceip <> '118.113.25.140' THEN languagecode ELSE NULL END END)) AS s6 
                    FROM uservisits

 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-12-29' and '2025-01-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.devicearch = 'x86'
                    GROUP BY uservisits.languagecode
                ), CTE12 AS 
                ( 
                    SELECT uservisits.languagecode, null AS topic, 
                    (COUNT(DISTINCT CASE WHEN ((case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname 
                        THEN 1 ELSE NULL END) * 1) = (case when agents.operatingsystem = 'Windows 10' AND uservisits.useragent = agents.agentname THEN 1 ELSE NULL END) THEN
                        languagecode ELSE NULL END)) AS s6 
                    FROM uservisits

 INNER JOIN agents ON uservisits.useragent = agents.agentname 

                    WHERE 
                    uservisits.visitdate between '2024-12-29' and '2025-01-29' AND
                    uservisits.countrycode IN ('CHE', 'URY', 'MKD') 
                    AND agents.devicearch = 'ARM'
                    GROUP BY uservisits.languagecode
                ), 
                CTE13 AS 
                ( 
                    SELECT CTE2.languagecode, CTE2.topic, (((COALESCE(CTE2.s1,0)*1.0)/8)-(((COALESCE(CTE3.s1,0)*1.0)/8)+((COALESCE(CTE4.s1,0)*1.0)/8)))/(CTE5.s1) AS s1 
                    FROM CTE2
LEFT JOIN  CTE3 ON CTE2.languagecode = CTE3.languagecode 
LEFT JOIN  CTE4 ON CTE2.languagecode = CTE4.languagecode 
LEFT JOIN  CTE5 ON CTE2.languagecode = CTE5.languagecode 
                ), CTE14 AS 
                ( 
                    SELECT CTE4.languagecode, CTE4.topic, (((COALESCE(CTE4.s5,0)*1.0)/8))/(CTE5.s5) AS s5 
                    FROM CTE4
LEFT JOIN  CTE5 ON CTE4.languagecode = CTE5.languagecode 
                ), CTE15 AS 
                ( 
                    SELECT CTE3.languagecode, CTE3.topic, (((COALESCE(CTE3.s4,0)*1.0)/8))/(CTE5.s4) AS s4 
                    FROM CTE3
LEFT JOIN  CTE5 ON CTE3.languagecode = CTE5.languagecode 
                ), CTE16 AS 
                ( 
                    SELECT CTE2.languagecode, CTE2.topic, CASE WHEN (((COALESCE(CTE2.s2,0)*1.0)/8)-((COALESCE(CTE4.s2,0)*1.0)/8)) <>0 THEN 100*(((COALESCE(CTE2.s2,0)*1.0)/8)-(((COALESCE(CTE3.s2,0)*1.0)/8)+((COALESCE(CTE4.s2,0)*1.0)/8)))/(((COALESCE(CTE2.s2,0)*1.0)/8)-((COALESCE(CTE4.s2,0)*1.0)/8)) ELSE 0 END AS s2 
                    FROM CTE2
LEFT JOIN  CTE3 ON CTE2.languagecode = CTE3.languagecode 
LEFT JOIN  CTE4 ON CTE2.languagecode = CTE4.languagecode 
                ), CTE17 AS 
                ( 
                    SELECT CTE6.languagecode, CTE6.topic, CASE WHEN (((COALESCE(CTE2.s3,0)*1.0)/8)-(((COALESCE(CTE3.s3,0)*1.0)/8)+((COALESCE(CTE4.s3,0)*1.0)/8)))<>0 THEN (CTE6.s3)/(((COALESCE(CTE2.s3,0)*1.0)/8)-(((COALESCE(CTE3.s3,0)*1.0)/8)+((COALESCE(CTE4.s3,0)*1.0)/8))) ELSE 0 END AS s3 
                    FROM CTE6
LEFT JOIN  CTE2 ON CTE6.languagecode = CTE2.languagecode 
LEFT JOIN  CTE3 ON CTE6.languagecode = CTE3.languagecode 
LEFT JOIN  CTE4 ON CTE6.languagecode = CTE4.languagecode 
                ), CTE18 AS 
                ( 
                    SELECT CTE7.languagecode, CTE7.topic, (((CASE WHEN (COALESCE(CTE8.s6,0)*1.0)<>0 THEN (COALESCE(CTE7.s6,0)*1.0)/(COALESCE(CTE8.s6,0)*1.0) ELSE 0 END)+(CASE WHEN (COALESCE(CTE10.s6,0)*1.0)<>0 THEN (COALESCE(CTE9.s6,0)*1.0)/(COALESCE(CTE10.s6,0)*1.0)ELSE 0 END)+(CASE WHEN (COALESCE(CTE12.s6,0)*1.0) <>0 THEN (COALESCE(CTE11.s6,0)*1.0)/(COALESCE(CTE12.s6,0)*1.0)ELSE 0 END ))/3)*100 AS s6 
                    FROM CTE7
LEFT JOIN  CTE8 ON CTE7.languagecode = CTE8.languagecode 
LEFT JOIN  CTE9 ON CTE7.languagecode = CTE9.languagecode 
LEFT JOIN  CTE10 ON CTE7.languagecode = CTE10.languagecode 
LEFT JOIN  CTE11 ON CTE7.languagecode = CTE11.languagecode 
LEFT JOIN  CTE12 ON CTE7.languagecode = CTE12.languagecode 
                ), 
                CTE19 AS 
                ( 
                    SELECT CAST(languagecode AS STRING) AS languagecode,
                    topic, 
                    MAX(s1) AS s1, MAX(s5) AS s5, MAX(s4) AS s4, MAX(s2) AS s2, MAX(s3) AS s3, MAX(s6) AS s6 
                    FROM 
(

SELECT
CTE13.languagecode, CTE13.topic, CTE13.s1, NULL AS s5, NULL AS s4, NULL AS s2, NULL AS s3, NULL AS s6
FROM
CTE13
UNION ALL

SELECT
CTE14.languagecode, CTE14.topic, NULL AS s1, CTE14.s5, NULL AS s4, NULL AS s2, NULL AS s3, NULL AS s6
FROM
CTE14
UNION ALL

SELECT
CTE15.languagecode, CTE15.topic, NULL AS s1, NULL AS s5, CTE15.s4, NULL AS s2, NULL AS s3, NULL AS s6
FROM
CTE15
UNION ALL

SELECT
CTE16.languagecode, CTE16.topic, NULL AS s1, NULL AS s5, NULL AS s4, CTE16.s2, NULL AS s3, NULL AS s6
FROM
CTE16
UNION ALL

SELECT
CTE17.languagecode, CTE17.topic, NULL AS s1, NULL AS s5, NULL AS s4, NULL AS s2, CTE17.s3, NULL AS s6
FROM
CTE17
UNION ALL

SELECT
CTE18.languagecode, CTE18.topic, NULL AS s1, NULL AS s5, NULL AS s4, NULL AS s2, NULL AS s3, CTE18.s6
FROM
CTE18
) T
GROUP BY languagecode, topic                    
                )              
SELECT *
FROM CTE19;

-- query 14
SELECT
    s.is_topic,
    COALESCE(COUNT(DISTINCT uv.sourceip), 0) AS t1visits
FROM
    uservisits uv
LEFT JOIN rankings r ON (coalesce(uv.destinationurl,'/')) = r.pageurl
LEFT JOIN ipaddresses i ON (coalesce(uv.sourceip,'0.0.0.0')) = i.ip
LEFT JOIN agents a ON uv.useragent = a.agentname
LEFT JOIN searchwords s ON uv.searchword = s.word
WHERE
  a.operatingsystem = 'macOS' AND 
  uv.visitdate >= '2022-11-21' AND uv.visitdate < '2022-12-22'
    AND coalesce(uv.countrycode, '') = 'ARE'
    AND (
        CASE
            WHEN uv.countrycode = '' AND uv.sourceip IS NOT NULL THEN 'Populated'
            WHEN uv.countrycode = '' THEN 'Not Populated'
            ELSE 'Populated'
        END = 'Populated'
    )
    AND (CASE WHEN (CASE
            WHEN 'Off' = 'Off' THEN TRUE
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            ELSE FALSE
        END) THEN 1 ELSE 0 END) = 1
     AND REGEXP_CONTAINS(a.browser, 'Firefox$')
GROUP BY
    1
HAVING COALESCE(COUNT(DISTINCT uv.sourceip), 0) > 0
ORDER BY
    2 DESC
LIMIT 50 OFFSET 50;

-- query 15
SELECT * FROM (
  SELECT *, DENSE_RANK() OVER (ORDER BY z___min_rank) as z___pivot_row_rank,
    RANK() OVER (PARTITION BY z__pivot_col_rank ORDER BY z___min_rank) as z__pivot_col_ordering,
    CASE WHEN z___min_rank = z___rank THEN 1 ELSE 0 END AS z__is_highest_ranked_cell
  FROM (
    SELECT *, MIN(z___rank) OVER (PARTITION BY t1dynamic_timeframe) as z___min_rank
    FROM (
      SELECT *, RANK() OVER (ORDER BY t1dynamic_timeframe ASC, z__pivot_col_rank) AS z___rank
      FROM (
        SELECT *, DENSE_RANK() OVER (ORDER BY CASE WHEN t1breakdown IS NULL THEN 1 ELSE 0 END, t1breakdown) AS z__pivot_col_rank
        FROM (
          SELECT
            CASE
              WHEN 'Date' = 'Date' THEN FORMAT_TIMESTAMP('%Y-%m-%d', uv.visitdate)
              WHEN 'Date' = 'Week' THEN FORMAT_TIMESTAMP('%Y-%m-%d', date_trunc(uv.visitdate, WEEK))
              WHEN 'Date' = 'Month' THEN FORMAT_DATE('%Y-%m', DATE_TRUNC(uv.visitdate, MONTH))
            END AS t1dynamic_timeframe,
            s.word AS t1breakdown,
            COUNT(*) AS t1visits,
            SUM(CASE WHEN uv.duration > 30 THEN 1 ELSE 0 END) AS t1successful_visits
          FROM uservisits uv
          LEFT JOIN searchwords s ON uv.searchword = s.word
          WHERE uv.sourceip LIKE '212%' and visitdate between '2023-05-18' and '2023-05-19' 
          GROUP BY 1, 2
        ) ww
      ) bb WHERE z__pivot_col_rank <= 10000
    ) aa
  ) xx
) zz
WHERE (z__pivot_col_rank <= 50 OR z__is_highest_ranked_cell = 1) AND (z___pivot_row_rank <= 500 OR z__pivot_col_ordering = 1)
ORDER BY z___pivot_row_rank;

-- query 16
SELECT r.*, v.visitdate, v.adrevenue
FROM uservisits v inner join rankings r on v.destinationurl = r.pageurl
WHERE sourceip ='113.191.7.12' and visitdate between '2022-09-25' and '2022-10-01';

-- query 17
SELECT destinationurl, COUNT(*) AS visit_count FROM uservisits WHERE (countrycode ='ISR' or countrycode = 'VNM') 
 AND EXTRACT(YEAR FROM visitDate) = 2023 AND EXTRACT(MONTH FROM visitDate) = 9
 GROUP BY destinationurl LIMIT 100;

-- query 18
SELECT destinationurl, sum(adrevenue) as adrevenues
from uservisits
WHERE searchword = 'success'
    and countrycode = 'ALB'
    and visitdate BETWEEN '2022-02-19' AND '2022-02-24'
    and REGEXP_CONTAINS(destinationurl, '^.com')
group by destinationurl
order by adrevenues DESC, destinationurl
LIMIT 20000;

-- query 19
WITH CTE1
AS
(
SELECT  
  searchword AS searchword,
		B.languagecode,
		SUM(B.duration) AS sum_duration
FROM uservisits B
INNER JOIN agents  ON   B.useragent = agents.agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND B.visitdate between '2023-12-04' and '2023-12-06'
AND B.countrycode  IN ('HKG')
AND B.sourceip IN ('190.68.109.55')
GROUP BY searchword, B.languagecode
),

CTE2
AS
(
SELECT DISTINCT A.languagecode  
FROM uservisits A 
INNER JOIN agents 
ON   A.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.visitdate between '2023-12-04' and '2023-12-06'
AND A.sourceip IN ('190.68.109.55')
),

CTE3
AS
(
SELECT
	searchword AS searchword,
	A.languagecode,
	COUNT(A.languagecode)  languagecode_cnt
FROM uservisits A
INNER JOIN agents 
ON   A.useragent = agentname
INNER JOIN searchwords AC
ON A.searchword =AC.word
INNER JOIN CTE2 AC2
ON A.languagecode = AC2.languagecode
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.visitdate between '2023-12-04' and '2023-12-06'
AND A.countrycode  IN ('HKG')
AND A.sourceip IN ('190.68.109.55')
GROUP BY searchword, A.languagecode
) ,

CTE4
AS
(
SELECT 
searchword AS searchword,
B.languagecode,
SUM(B.duration) AS sum_duration
FROM uservisits B
INNER JOIN ipaddresses BD
ON B.sourceip=BD.ip
INNER JOIN agents 
ON   B.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera') 
AND B.countrycode  IN ('HKG')
AND B.visitdate between '2023-12-04' and '2023-12-06'
GROUP BY searchword, B.languagecode
) ,

CTE5
AS
(
SELECT DISTINCT A.languagecode  
FROM uservisits A
INNER JOIN ipaddresses BD
ON A.sourceip=BD.ip
INNER JOIN agents 
ON   A.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.countrycode IN('HKG')
AND A.visitdate between '2023-12-04' and '2023-12-06'
),

CTE6
AS
(SELECT
searchword AS searchword,
A.languagecode,
COUNT(A.languagecode )  languagecode_cnt
FROM uservisits A
INNER JOIN ipaddresses BD
ON A.sourceip=BD.ip
INNER JOIN agents 
ON   A.useragent = agentname 
INNER JOIN searchwords AC
ON A.searchword =AC.word
INNER JOIN CTE5 AC2
ON A.languagecode = AC2.languagecode
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.countrycode  IN ('HKG')
AND A.visitdate between '2023-12-04' and '2023-12-06'
AND AC.is_topic
GROUP BY searchword, A.languagecode

),


CTE7
AS
(
SELECT 
searchword AS searchword,
B.languagecode,
SUM(B.duration) AS sum_duration
FROM uservisits B 
INNER JOIN ipaddresses BD
ON B.sourceip=BD.ip
INNER JOIN agents 
ON   B.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera') 
AND B.countrycode  IN ('HKG')
AND B.visitdate between '2023-12-04' and '2023-12-06'
GROUP BY searchword, B.languagecode
), 

CTE8
AS
(
SELECT DISTINCT A.languagecode  
FROM uservisits A
INNER JOIN ipaddresses BD
ON A.sourceip=BD.ip
INNER JOIN agents 
ON   A.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.visitdate between '2023-12-04' and '2023-12-06'
),

CTE9
AS
(SELECT
searchword AS searchword,
A.languagecode,
COUNT(A.languagecode )  languagecode_cnt
FROM uservisits A
INNER JOIN ipaddresses BD
ON A.sourceip=BD.ip 
INNER JOIN agents 
ON   A.useragent = agentname
INNER JOIN searchwords AC
ON A.searchword =AC.word
INNER JOIN CTE8 AC2
ON A.languagecode = AC2.languagecode

WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.countrycode  IN ('HKG')
AND A.visitdate between '2023-12-04' and '2023-12-06'  
AND AC.is_topic  
GROUP BY searchword, A.languagecode

),

CTE10
AS
(
SELECT 
searchword AS searchword,
B.languagecode,
SUM(B.duration) AS sum_duration
FROM uservisits B 
INNER JOIN agents 
ON   B.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND B.countrycode  IN ('HKG')
AND B.sourceip IN ('190.68.109.55')
AND B.visitdate between '2023-12-04' and '2023-12-06'  
GROUP BY searchword, B.languagecode
),

CTE11
AS
(
SELECT DISTINCT A.languagecode  
FROM uservisits A
INNER JOIN agents 
ON   A.useragent = agentname 
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.sourceip IN ('190.68.109.55')
AND A.visitdate between '2023-12-04' and '2023-12-06'  
),

CTE12
AS
(SELECT
searchword AS searchword,
A.languagecode,
COUNT(A.languagecode )  languagecode_cnt
FROM uservisits A 
INNER JOIN agents 
ON   A.useragent = agentname 
INNER JOIN searchwords AC
ON A.searchword =AC.word
INNER JOIN CTE11 AC2
ON A.languagecode = AC2.languagecode
WHERE agents.operatingsystem = 'macOS' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
AND A.countrycode  IN ('HKG')
AND A.sourceip IN ('190.68.109.55')
AND A.visitdate between '2023-12-04' and '2023-12-06'    
AND AC.is_topic  
GROUP BY searchword, A.languagecode
),
CTE13 AS
(

SELECT  '1' AS searchword,
'ON DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration = 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE3 AS C2
INNER JOIN CTE1 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '2' AS searchword,
'OVER DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration < 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE3 AS C2
INNER JOIN CTE1 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '3' AS searchword,
'UNDER DURATION' AS where_duration,
COUNT( DISTINCT CASE WHEN C1.sum_duration > 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE3 AS C2
INNER JOIN CTE1 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL
),
CTE14 AS
(

SELECT  
  	'1' AS searchword,
	'ON DURATION' AS where_duration,
	COUNT(DISTINCT CASE WHEN C1.sum_duration = 10000
    	THEN C1.languagecode
   		END )AS sum_duration_DATA
FROM CTE6 AS C2
INNER JOIN CTE4 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '2' AS searchword,
'OVER DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration < 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE6 AS C2
INNER JOIN CTE4 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '3' AS searchword,
'UNDER DURATION' AS where_duration,
COUNT( DISTINCT CASE WHEN C1.sum_duration > 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE6 AS C2
INNER JOIN CTE4 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL
),
CTE15 AS
(

SELECT  '1' AS searchword,
'ON DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration = 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE9 AS C2
INNER JOIN CTE7 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '2' AS searchword,
'OVER DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration < 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE9 AS C2
INNER JOIN CTE7 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '3' AS searchword,
'UNDER DURATION' AS where_duration,
COUNT( DISTINCT CASE WHEN C1.sum_duration > 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM CTE9 AS C2
INNER JOIN CTE7 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
GROUP BY ALL
),

CTE16 AS
(

SELECT  '1' AS searchword,
'ON DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration = 10000 
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM uservisits AS C2
INNER JOIN CTE10 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
WHERE C1.searchword='u'
  AND C2.visitdate between '2023-12-04' and '2023-12-06'  
GROUP BY ALL
    
UNION ALL

SELECT  '2' AS searchword,
'OVER DURATION' AS where_duration,
COUNT(DISTINCT CASE WHEN C1.sum_duration < 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM uservisits AS C2
INNER JOIN CTE10 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
AND C2.visitdate between '2023-12-04' and '2023-12-06'    
WHERE C1.searchword='u'
GROUP BY ALL

UNION ALL

SELECT  '3' AS searchword,
'UNDER DURATION' AS where_duration,
COUNT( DISTINCT CASE WHEN C1.sum_duration > 10000
    THEN C1.languagecode
   END )AS sum_duration_DATA
FROM uservisits AS C2
INNER JOIN CTE10 C1
ON C1.languagecode = C2.languagecode
AND C1.searchword=C2.searchword
AND C2.visitdate between '2023-12-04' and '2023-12-06'    
WHERE C1.searchword='u'
GROUP BY ALL
)

SELECT searchword,where_duration,SUM(sum_duration_DATA) FROM (

SELECT searchword AS searchword,
where_duration AS where_duration,
(C1.sum_duration_DATA) AS sum_duration_DATA
FROM CTE13 AS C1
WHERE  0<>(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('190.68.109.55'))

UNION ALL
SELECT searchword AS searchword,
where_duration AS where_duration,
(C2.sum_duration_DATA) AS sum_duration_DATA
FROM CTE16 AS C2
WHERE  0<>(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('190.68.109.55'))

UNION ALL
SELECT searchword AS searchword,
where_duration AS where_duration,
(C3.sum_duration_DATA) AS sum_duration_DATA
FROM CTE14 AS C3
WHERE  0=(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('190.68.109.55'))

UNION ALL
SELECT searchword AS searchword,
where_duration AS where_duration,
(C4.sum_duration_DATA) AS sum_duration_DATA
FROM CTE15 AS C4
WHERE  0=(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('190.68.109.55'))

)
GROUP BY searchword,where_duration;

-- query 20
with origin_tab as (
    select
        *
    from
        uservisits
    where
  		visitdate between '2024-08-17' and '2024-08-18'
        and countrycode in ('ARG', 'SWE')
        and REGEXP_CONTAINS(destinationurl, '.*(ad|b$)')
        and adrevenue > 0.9
),
searchwords_tab as (
    select * from searchwords where word like 'the%'
    union all
    select * from searchwords where word like 'tax%'
    union all
    select * from searchwords where word like 'fee%'
    union all
    select * from searchwords where word like 'hit%'
    union all
    select * from searchwords where word like 'fri%'
),
result_tab as (
    select *
    from origin_tab
    where visitdate between '2024-08-02' and '2024-10-16'
)
select 
(
    select
        ARRAY_AGG(destinationurl)
    from
        (
            select
                destinationurl
            from
                result_tab
            where
                searchword in (
                    select
                        distinct word
                    from
                        searchwords_tab
                    where
                        word_hash in (8637088342410109700)
                )
            order by
                adrevenue desc
            limit
                3
        )
) f0
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (-5713198883824118089)) 
order by adrevenue desc limit 3)) f1
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (2454218397564696334)) 
order by adrevenue desc limit 3)) f2
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (-1820666311870301227)) 
order by adrevenue desc limit 3)) f3
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (8644561162363758030, 1590051461067175528, -5053658049239510121, 7810904927140280516, -7009170756344001614,-5086883951133945964, -514832142673359269, 6127045034804176891, 1826441640885516856, 8381368794783220959)) 
order by adrevenue desc limit 3)) f4
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (6199526617341103713))
order by adrevenue desc limit 3)) f5
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (7740847646030491569, 7285727206792179080, 8629489941932462024, -1393525601299598534, 7418795809015032129,-7967245323559166905, 7322682162708365250)) 
order by adrevenue desc limit 3)) f6
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (551453269330966873)) 
order by adrevenue desc limit 3)) f7;

-- query 21
SELECT
    uv.destinationurl AS uv_destinationurl,
    i.asname AS i_asname,
    a.operatingsystem AS a_operatingsystem,
    a.browser AS a_browser,
    COALESCE(SUM(uv.adrevenue), 0) AS uv_total_adrevenue,
    COUNT(DISTINCT uv.sourceip) AS uv_unique_visitors,
    NULLIF(SUM(uv.duration), 0) / NULLIF(COUNT(DISTINCT uv.sourceip), 0) AS uv_avg_duration_per_visitor,
    SUM(CASE WHEN uv.duration > 60 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT uv.sourceip), 0) AS uv_high_engagement_ratio,
    r.pagerank AS r_pagerank,
    COALESCE(SUM(CASE WHEN s.is_topic THEN uv.adrevenue ELSE 0 END), 0) / NULLIF(SUM(uv.adrevenue), 0) AS uv_topic_revenue_contribution
FROM (
    SELECT *
    FROM uservisits
    WHERE visitdate >= '2022-12-23' AND visitdate < '2023-01-22' and countrycode = 'URY'
    LIMIT 1
) uv
LEFT JOIN (
    SELECT *
    FROM rankings
) r ON uv.destinationurl = r.pageurl
LEFT JOIN (
    SELECT *
    FROM ipaddresses
) i ON uv.sourceip = i.ip
LEFT JOIN (
    SELECT *
    FROM agents
) a ON uv.useragent = a.agentname
LEFT JOIN (
    SELECT *
    FROM searchwords
) s ON uv.searchword = s.word
WHERE uv.countrycode = 'URY' AND a.operatingsystem = 'Windows 10'
AND (CASE WHEN (CASE
            WHEN 'Off' = 'Off' THEN TRUE
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN date_add(uv.visitdate, INTERVAL 1 DAY) > CURRENT_DATE
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, WEEK), INTERVAL -1 WEEK)
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_add(date_trunc(CURRENT_DATE, MONTH), INTERVAL -1 MONTH)
            ELSE FALSE
        END) THEN 1 ELSE 0 END) = 1
GROUP BY uv_destinationurl, i.asname, a.operatingsystem, a.browser, r.pagerank
ORDER BY uv_total_adrevenue DESC
LIMIT 50 OFFSET 50;

-- query 22
SELECT
    uv.sourceip AS id,
    CONCAT(i.asname, ' - ', a.browser) AS group_name,
    COUNT(*) AS f1,
    SUM(CASE WHEN uv.duration > 30 THEN 1 ELSE 0 END) AS f1_tran_success,
    ROUND((SUM(CASE WHEN uv.duration > 30 THEN 1 ELSE 0 END) / (COUNT(*)+1)) * 100, 2) AS f1_tran_success_rate,
    SUM(CASE WHEN uv.duration <= 30 THEN 1 ELSE 0 END) AS f1_tran_decline,
    ROUND((SUM(CASE WHEN uv.duration <= 30 THEN 1 ELSE 0 END) / (COUNT(*)+1)) * 100, 2) AS f1_tran_decline_rate,
    SUM(CASE WHEN s.is_topic THEN 1 ELSE 0 END) AS f1_tran_auth,
    SUM(CASE WHEN s.is_topic AND uv.duration > 30 THEN 1 ELSE 0 END) AS f1_tran_auth_success,
    ROUND((SUM(CASE WHEN s.is_topic AND uv.duration > 30 THEN 1 ELSE 0 END) / (SUM(CASE WHEN s.is_topic THEN 1 ELSE 0 END)+1)) * 100, 2) AS f1_tran_auth_success_rate,
    SUM(CASE WHEN s.is_topic AND uv.duration <= 30 THEN 1 ELSE 0 END) AS f1_tran_auth_decline,
    ROUND((SUM(CASE WHEN s.is_topic AND uv.duration <= 30 THEN 1 ELSE 0 END) / (SUM(CASE WHEN s.is_topic THEN 1 ELSE 0 END)+1)) * 100, 2) AS f1_tran_auth_decline_rate,
    COUNT(DISTINCT uv.sourceip) AS f1_cust,
    COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.sourceip END) AS f1_cust_success,
    ROUND((COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.sourceip END) / (COUNT(DISTINCT uv.sourceip)+1)) * 100, 2) AS f1_cust_success_rate,
    (COUNT(DISTINCT uv.sourceip) - COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.sourceip END)) AS f1_cust_decline,
    ROUND(((COUNT(DISTINCT uv.sourceip) - COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.sourceip END)) / (COUNT(DISTINCT uv.sourceip)+1)) * 100, 2) AS f1_cust_decline_rate,
    COUNT(DISTINCT uv.destinationurl) AS f1_order,
    COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.destinationurl END) AS f1_order_success,
    ROUND((COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.destinationurl END) / (COUNT(DISTINCT uv.destinationurl)+1)) * 100, 2) AS f1_order_success_rate,
    (COUNT(DISTINCT uv.destinationurl) - COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.destinationurl END)) AS f1_order_decline,
    ROUND(((COUNT(DISTINCT uv.destinationurl) - COUNT(DISTINCT CASE WHEN uv.duration > 30 THEN uv.destinationurl END)) / (COUNT(DISTINCT uv.destinationurl)+1)) * 100, 2) AS f1_order_decline_rate,
    SUM(CASE WHEN s.is_topic AND uv.duration > 30 THEN 1 ELSE 0 END) AS f1_recurring,
    ROUND((SUM(CASE WHEN s.is_topic AND uv.duration > 30 THEN 1 ELSE 0 END) / (SUM(CASE WHEN uv.duration > 30 THEN 1 ELSE 0 END)+1)) * 100, 2) AS f1_recurring_rate,
    SUM(CASE WHEN s.is_topic = FALSE AND uv.duration > 30 THEN 1 ELSE 0 END) AS f1_ots,
    ROUND((SUM(CASE WHEN s.is_topic = FALSE AND uv.duration > 30 THEN 1 ELSE 0 END) / (SUM(CASE WHEN uv.duration > 30 THEN 1 ELSE 0 END)+1)) * 100, 2) AS f1_ots_rate
FROM uservisits uv
LEFT JOIN ipaddresses i ON uv.sourceip = i.ip
LEFT JOIN agents a ON uv.useragent = a.agentname
LEFT JOIN searchwords s ON uv.searchword = s.word
WHERE uv.visitdate >= '2024-07-25' AND uv.visitdate < '2024-07-28'
    AND a.operatingsystem = 'macOS'
GROUP BY 1, 2
ORDER BY f1 DESC
LIMIT 50;

-- query 23
WITH c_curr_searchwords AS (
    SELECT word AS keyword
    FROM searchwords
    WHERE word_id = 6813205734331865088
),
filtered_dpd AS (
    SELECT uv.sourceip AS c_id, 'config_sample' AS scraping_conf_id, uv.duration AS clicks,
           uv.visitdate AS insert_time, sw.word AS keyword, r.pagerank AS pos_o,
           uv.visitdate AS scrape_date, 'o' AS serp_type, a.browser AS site, uv.destinationurl AS url,
           r.avgduration AS volume, 1.0 AS cpc, uv.countrycode AS country
    FROM uservisits uv
    JOIN searchwords sw ON uv.searchword = sw.word
    JOIN rankings r ON uv.destinationurl = r.pageurl
    JOIN agents a ON uv.useragent = a.agentname
    WHERE sw.word IN (SELECT keyword FROM c_curr_searchwords)
    AND uv.visitdate BETWEEN '2023-12-15' AND '2024-01-14' and uv.sourceip = '45.125.176.154'
),
filtered_d AS (
    SELECT fdp.country, sw.word AS keyword, '2022-12' AS yearmonth, 5 AS d
    FROM searchwords sw
    JOIN filtered_dpd fdp ON sw.word = fdp.keyword
    WHERE sw.is_topic = true
),
filtered_i AS (
    SELECT fdp.country, sw.word AS keyword, '2022-12' AS yearmonth, 'informational' AS primary_i
    FROM searchwords sw
    JOIN filtered_dpd fdp ON sw.word = fdp.keyword
    WHERE sw.is_topic = true
),
tags_by_c AS (
    SELECT 'config_sample' AS c_id, sw.word AS keyword, 'sample_tag' AS tag
    FROM searchwords sw
    WHERE sw.word_id = 6813205734331865088
),
searchwords_with_all_filters AS (
    SELECT fdp.*
    FROM filtered_dpd fdp
),
filtered_tags AS (
    SELECT fdp.scraping_conf_id, fdp.keyword, tb.tag, fdp.volume,
           MIN(CASE WHEN site = 'google.com' OR REGEXP_CONTAINS(LOWER(site), r'%.google.com%') THEN pos_o ELSE 100 END) AS top_pos,
           fdp.scrape_date, SUM(fdp.clicks) AS clicks
    FROM tags_by_c tb
    LEFT JOIN searchwords_with_all_filters fdp ON fdp.keyword = tb.keyword
    GROUP BY fdp.scraping_conf_id, fdp.keyword, tb.tag, fdp.scrape_date, volume
),
weighted_rank_data AS (
    SELECT t.scraping_conf_id, t.keyword, t.tag, t.top_pos, t.scrape_date, volume,
           CASE WHEN COALESCE(volume, 0) != 0 THEN volume * t.top_pos END AS weighted_rank,
           CASE WHEN COALESCE(volume, 0) != 0 AND t.top_pos BETWEEN 1 AND 30 THEN volume * (31 - t.top_pos) ELSE 0 END AS weighted_visibility
    FROM filtered_tags t
),
clicks_sum AS (
    SELECT tag, scrape_date, SUM(clicks) AS clicks
    FROM filtered_tags
    GROUP BY tag, scrape_date
),
volume_total AS (
    SELECT tag, scrape_date, SUM(volume) AS total_volume
    FROM weighted_rank_data
    GROUP BY tag, scrape_date
),
metrics_per_day AS (
    SELECT wrd.tag, wrd.scrape_date, COALESCE(cs.clicks, 0) AS clicks, vt.total_volume,
           CASE WHEN vt.total_volume = 0 THEN 100 ELSE SUM(weighted_rank) / vt.total_volume END AS avg_weight_pos,
           CASE WHEN vt.total_volume = 0 THEN 0 ELSE SUM(weighted_visibility) / (30 * vt.total_volume) END AS visibility
    FROM weighted_rank_data wrd
    LEFT JOIN clicks_sum cs ON cs.tag = wrd.tag AND cs.scrape_date = wrd.scrape_date
    LEFT JOIN volume_total vt ON vt.tag = wrd.tag AND vt.scrape_date = wrd.scrape_date
    GROUP BY wrd.tag, wrd.scrape_date, cs.clicks, vt.total_volume
    ORDER BY wrd.tag, wrd.scrape_date
)
SELECT m.tag, MAX(total_volume) AS total_volume,
       ARRAY_AGG(m.scrape_date) AS avg_weight_position_dates,
       ARRAY_AGG(avg_weight_pos) AS avg_weight_position,
       ARRAY_AGG(clicks) AS clicks,
       ARRAY_AGG(visibility) AS visibility
FROM metrics_per_day m
GROUP BY m.tag;

-- query 24
WITH
  word_titles AS (
    SELECT
      word_id AS id,
      MAX_BY(word, firstseen) AS word_title
    FROM
      searchwords
    GROUP BY
      word_id
  ),
  base AS (
    SELECT
      uv.sourceip AS stream_id,
      ANY_VALUE(uv.countrycode) AS source_id,
      ANY_VALUE(uv.destinationurl) AS destination_id,
      ANY_VALUE(uv.visitdate) AS started_at,
      SUM(uv.duration) / 3600 AS f1,
      SUM(uv.duration * uv.adrevenue) / 3600 AS f2,
      COUNT(uv.sourceip) AS max_ccv,
      CASE
        WHEN SUM(uv.duration) > 3600 THEN SUM(uv.duration * uv.adrevenue) / SUM(uv.duration)
        ELSE COUNT(uv.sourceip)
      END AS avg_ccv,
      MAX(uv.adrevenue) - MIN(uv.adrevenue) AS new_followers,
      ARRAY_AGG(DISTINCT uv.languagecode) AS languages,
      ARRAY_AGG(DISTINCT uv.searchword) AS titles
    FROM
      uservisits uv
    WHERE
      uv.visitdate BETWEEN '2023-07-12' AND '2023-07-14'
    GROUP BY
      uv.sourceip
  ),
  samples AS (
    SELECT
      uv.sourceip AS stream_id,
      ARRAY_AGG(uv.visitdate) AS samples_ts,
      ARRAY_AGG(uv.duration) AS samples_viewers,
      ARRAY_AGG(uv.searchword) AS samples_title,
      ARRAY_AGG(sw.word_id) AS samples_word_id,
      ARRAY_AGG(gt.word_title) AS samples_word_title
    FROM
      uservisits uv
      JOIN searchwords sw ON uv.searchword = sw.word
      LEFT JOIN word_titles gt ON gt.id = sw.word_id
    WHERE
      uv.visitdate BETWEEN '2023-07-12' AND '2023-07-14'
    GROUP BY
      uv.sourceip
  ),
  group_title AS (
    SELECT
      uv.sourceip AS stream_id,
      ARRAY_AGG(uv.searchword) AS title_groups_title,
      ARRAY_AGG(uv.visitdate) AS title_groups_first_seen,
      ARRAY_AGG(uv.duration) AS title_groups_f1,
      ARRAY_AGG(uv.duration * uv.adrevenue) AS title_groups_f2
    FROM
      uservisits uv
    WHERE
      uv.visitdate BETWEEN '2023-07-12' AND '2023-07-14'
    GROUP BY
      uv.sourceip
  ),
  group_word AS (
    SELECT
      uv.sourceip AS stream_id,
      ARRAY_AGG(sw.word_id) AS word_groups_id,
      ARRAY_AGG(uv.visitdate) AS word_groups_first_seen,
      ARRAY_AGG(uv.duration) AS word_groups_f1,
      ARRAY_AGG(uv.duration * uv.adrevenue) AS word_groups_f2,
      ARRAY_AGG(gt.word_title) AS word_groups_title
    FROM
      uservisits uv
      JOIN searchwords sw ON uv.searchword = sw.word
      LEFT JOIN word_titles gt ON gt.id = sw.word_id
    WHERE
      uv.visitdate BETWEEN '2023-07-12' AND '2023-07-14'
    GROUP BY
      uv.sourceip
  ),
  group_word_and_title AS (
    SELECT
      uv.sourceip AS stream_id,
      ARRAY_AGG(sw.word_id) AS word_title_groups_word_id,
      ARRAY_AGG(uv.searchword) AS word_title_groups_stream_title,
      ARRAY_AGG(uv.visitdate) AS word_title_groups_first_seen,
      ARRAY_AGG(uv.duration) AS word_title_groups_f1,
      ARRAY_AGG(uv.duration * uv.adrevenue) AS word_title_groups_f2,
      ARRAY_AGG(uv.adrevenue) AS word_title_groups_max_ccv
    FROM
      uservisits uv
      JOIN searchwords sw ON uv.searchword = sw.word
    WHERE
      uv.visitdate BETWEEN '2023-07-12' AND '2023-07-14'
    GROUP BY
      uv.sourceip
  )
SELECT
  b.source_id,
  b.destination_id,
  b.started_at,
  b.f1,
  b.f2,
  b.max_ccv,
  b.avg_ccv,
  b.new_followers,
  b.languages,
  b.titles,
  s.samples_ts,
  s.samples_viewers,
  s.samples_title,
  s.samples_word_id,
  s.samples_word_title,
  gt.title_groups_title,
  gt.title_groups_first_seen,
  gt.title_groups_f1,
  gt.title_groups_f2,
  gg.word_groups_id,
  gg.word_groups_first_seen,
  gg.word_groups_f1,
  gg.word_groups_f2,
  gg.word_groups_title,
  ggt.word_title_groups_word_id,
  ggt.word_title_groups_stream_title,
  ggt.word_title_groups_first_seen,
  ggt.word_title_groups_f1,
  ggt.word_title_groups_f2,
  ggt.word_title_groups_max_ccv,
FROM
  base b
  LEFT JOIN samples s ON s.stream_id = b.stream_id
  LEFT JOIN group_title gt ON gt.stream_id = b.stream_id
  LEFT JOIN group_word gg ON gg.stream_id = b.stream_id
  LEFT JOIN group_word_and_title ggt ON ggt.stream_id = b.stream_id
ORDER BY
  b.started_at ASC
limit 100;

-- query 25
WITH
  base_metrics AS (
    SELECT
      uv.countrycode AS country,
      sw.word AS searchword,
      COUNT(uv.sourceip) AS clicks,
      SUM(uv.duration) AS volume,
      (SUM(uv.duration) - AVG(SUM(uv.duration)) OVER (PARTITION BY sw.word)) / AVG(SUM(uv.duration)) OVER (PARTITION BY sw.word) AS volume_trend, -- Simplified trend within the month
      MAX(uv.countrycode) AS top_country, -- Assuming a simplified logic for top_country
      COUNT(DISTINCT uv.destinationurl) AS total_sites
    FROM
      uservisits uv
      JOIN searchwords sw ON uv.searchword = sw.word
    WHERE
      uv.countrycode = 'NZL'
      AND uv.visitdate >= DATE '2022-02-06'
      AND uv.visitdate < DATE '2022-02-08'
    GROUP BY
      uv.countrycode,
      sw.word
  ),

  base_site AS (
    SELECT
      sw.word AS searchword,
      uv.destinationurl AS site
    FROM
      uservisits uv
      JOIN searchwords sw ON uv.searchword = sw.word
    WHERE
      uv.countrycode = 'NZL'
      AND uv.visitdate >= DATE '2022-02-06'
      AND uv.visitdate < DATE '2022-03-08'
  ),

  original_count AS (
    SELECT
      SUM(total_sites) AS original_total
    FROM
      base_metrics
    WHERE
      searchword = 'remove'
  ),

  site_intersection AS (
    SELECT
      b.searchword,
      COUNT(b.site) AS intersection
    FROM
      base_site b
    WHERE
      b.site IN (SELECT site FROM base_site WHERE searchword = 'remove')
    GROUP BY
      b.searchword
  ),

  joined AS (
    SELECT
      kwm.country,
      kwm.searchword,
      kwm.clicks,
      kwm.volume,
      kwm.volume_trend,
      kwm.top_country,
      kwm.total_sites AS total,
      vi.intersection
    FROM
      base_metrics kwm
      JOIN site_intersection vi ON kwm.searchword = vi.searchword
    WHERE
      kwm.searchword IN (SELECT searchword FROM site_intersection UNION ALL SELECT 'some-value-that-not-exist')
  ),

  related AS (
    SELECT
      j.country,
      j.searchword,
      j.clicks,
      j.volume,
      j.volume_trend,
      j.top_country,
      (j.intersection + 0.0) / (j.total + o.original_total - j.intersection) AS score
    FROM
      joined j
    CROSS JOIN
      original_count o
    WHERE
      j.searchword != 'remove'
      AND NOT REGEXP_CONTAINS(LOWER(j.searchword), 'pattern1|text2|word3')
  )

SELECT
  *,
  (SELECT COUNT(*) FROM related) AS result_count,
  (SELECT MAX(score) FROM related) AS max_score
FROM related
ORDER BY score DESC
LIMIT 400 OFFSET 0;