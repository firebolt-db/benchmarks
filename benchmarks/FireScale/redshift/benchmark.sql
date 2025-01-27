-- select checksum(*) FROM uservisits;

-- select checksum(*) FROM rankings;

-- query 1
SELECT visitdate, sourceip, adrevenue 
FROM uservisits 
WHERE (visitdate BETWEEN '2022-04-10' AND '2022-04-24')
AND sourceip IN ('9.232.65.46')
AND countrycode = 'ISL';

-- query 2
with desktop as ( 
            select 
            date_trunc('month', visitdate) as year_month_day,
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
            date_trunc('month', visitdate) as year_month_day,
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
SELECT 
    languagecode,
    MAX(visitdate) AS visitdate,
    LISTAGG(countrycode, ',') AS countrycode
FROM uservisits
WHERE sourceip = '61.57.9.153' 
  AND visitdate BETWEEN '2023-07-03' AND '2023-07-04'
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
WHERE (visitdate >= '2021-03-24' AND visitdate <= DATE_ADD('DAY', 1, '2021-03-24'));

-- query 8
SELECT date_trunc('month', visitdate) as year_month_day,
COALESCE(SUM(duration), 0) as installs,
COALESCE(SUM(length(searchword)), 0) as billingCost,
SUM(CASE WHEN adrevenue <= 1.5 THEN duration ELSE 0 END) as revenueD7
FROM uservisits
WHERE (visitdate >= '2022-10-06' AND visitdate <= DATE_ADD('DAY', 1, '2022-10-06'))
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

-- query 13
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
                    uservisits.visitdate between '2024-07-29'::DATE and '2024-08-29'::DATE AND
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
                    uservisits.visitdate between '2024-07-29'::DATE and '2024-08-29'::DATE AND
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
                    uservisits.visitdate between '2024-07-29'::DATE and '2024-08-29'::DATE AND
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
                    uservisits.visitdate between '2024-07-29'::DATE and '2024-08-29'::DATE AND
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
                    uservisits.visitdate between '2024-09-29'::DATE and '2024-10-29'::DATE AND
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
                    uservisits.visitdate between '2024-12-29'::DATE and '2025-01-29'::DATE AND
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
                    uservisits.visitdate between '2024-12-29'::DATE and '2025-01-29'::DATE AND
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
                    uservisits.visitdate between '2024-12-29'::DATE and '2025-01-29'::DATE AND
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
                    uservisits.visitdate between '2024-12-29'::DATE and '2025-01-29'::DATE AND
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
                    uservisits.visitdate between '2024-12-29'::DATE and '2025-01-29'::DATE AND
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
                    uservisits.visitdate between '2024-12-29'::DATE and '2025-01-29'::DATE AND
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
                    SELECT CAST(languagecode AS VARCHAR(1000)) AS languagecode,
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
LEFT JOIN rankings r ON COALESCE(uv.destinationurl, '/') = r.pageurl
LEFT JOIN ipaddresses i ON COALESCE(uv.sourceip, '0.0.0.0') = i.ip
LEFT JOIN agents a ON uv.useragent = a.agentname
LEFT JOIN searchwords s ON uv.searchword = s.word
WHERE
    a.operatingsystem = 'macOS'
    AND uv.visitdate >= '2022-11-21' 
    AND uv.visitdate < '2022-12-22'
    AND COALESCE(uv.countrycode, '') = 'ARE'
    AND (
        CASE
            WHEN uv.countrycode = '' AND uv.sourceip IS NOT NULL THEN 'Populated'
            WHEN uv.countrycode = '' THEN 'Not Populated'
            ELSE 'Populated'
        END = 'Populated'
    )
    AND (
        CASE 
            WHEN 'Off' = 'Off' THEN TRUE
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week'
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            ELSE FALSE
        END
    ) = 1
    AND a.browser ~ 'Firefox$'
GROUP BY
    1
HAVING COALESCE(COUNT(DISTINCT uv.sourceip), 0) > 0
ORDER BY
    2 DESC
LIMIT 50;


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
              WHEN 'Date' = 'Date' THEN to_char(uv.visitdate, 'YYYY-MM-DD')::VARCHAR
              WHEN 'Date' = 'Week' THEN to_char(date_trunc('week', uv.visitdate), 'YYYY-MM-DD')::VARCHAR
              WHEN 'Date' = 'Month' THEN to_char(date_trunc('month', uv.visitdate), 'YYYY-MM')::VARCHAR
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
SELECT destinationurl, COUNT(*) AS visit_count FROM UserVisits WHERE (countrycode ='ISR' or countrycode = 'VNM') 
 AND EXTRACT(YEAR FROM visitDate) = 2023 AND EXTRACT(MONTH FROM visitDate) = 9
 GROUP BY destinationurl LIMIT 100;

-- query 18
SELECT destinationurl, SUM(adrevenue) AS adrevenues
FROM uservisits
WHERE searchword = 'success'
    and countrycode = 'ALB'
    and visitdate BETWEEN '2022-02-19' AND '2022-02-24'
    AND destinationurl ~ '^.com'
GROUP BY destinationurl
ORDER BY adrevenues DESC, destinationurl
LIMIT 20000;

-- query 19
WITH macos_uservisits AS (
    SELECT  
        B.searchword AS searchword,
        B.languagecode AS languagecode,
        SUM(B.duration) AS sum_duration
    FROM uservisits B
    INNER JOIN agents 
        ON B.useragent = agents.agentname 
    WHERE agents.operatingsystem = 'macOS' 
      AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
      AND B.visitdate BETWEEN '2023-12-04' AND '2023-12-06'
      AND B.countrycode IN ('HKG')
      AND B.sourceip IN ('190.68.109.55')
    GROUP BY B.searchword, B.languagecode
),

distinct_languages AS (
    SELECT DISTINCT 
        A.languagecode
    FROM uservisits A 
    INNER JOIN agents 
        ON A.useragent = agents.agentname 
    WHERE agents.operatingsystem = 'macOS' 
      AND agents.devicearch = 'x64'
      AND agents.browser IN ('Google Chrome', 'Safari', 'Opera')
),

all_languages_combined AS (
    SELECT DISTINCT 
        languagecode
    FROM uservisits
)

-- Final query combining the CTEs
SELECT 
    macos_uservisits.searchword,
    macos_uservisits.languagecode,
    macos_uservisits.sum_duration,
    CASE 
        WHEN macos_uservisits.languagecode IS NULL THEN 'Not Available'
        ELSE macos_uservisits.languagecode
    END AS language_description
FROM macos_uservisits
LEFT JOIN distinct_languages
    ON macos_uservisits.languagecode = distinct_languages.languagecode
LEFT JOIN all_languages_combined
    ON macos_uservisits.languagecode = all_languages_combined.languagecode
ORDER BY macos_uservisits.searchword;


-- query 20
WITH origin_tab AS (
    SELECT
        *
    FROM
        uservisits
    WHERE
        visitdate BETWEEN '2024-08-17'::DATE AND '2024-08-18'::DATE
        AND countrycode IN ('ARG', 'SWE')
        AND destinationurl ~* '.*(ad|b$)'
        AND adrevenue > 0.9
),
searchwords_tab AS (
    SELECT * FROM searchwords WHERE word LIKE 'the%'
    UNION ALL
    SELECT * FROM searchwords WHERE word LIKE 'tax%'
    UNION ALL
    SELECT * FROM searchwords WHERE word LIKE 'fee%'
    UNION ALL
    SELECT * FROM searchwords WHERE word LIKE 'hit%'
    UNION ALL
    SELECT * FROM searchwords WHERE word LIKE 'fri%'
),
result_tab AS (
    SELECT *
    FROM origin_tab
    WHERE visitdate BETWEEN '2024-08-02'::DATE AND '2024-10-16'::DATE
)
SELECT 
(
    SELECT
        LISTAGG(destinationurl, ', ')
    FROM
        (
            SELECT
                destinationurl, adrevenue 
            FROM
                result_tab
            WHERE
                searchword IN (
                    SELECT
                        DISTINCT word
                    FROM
                        searchwords_tab
                    WHERE
                        word_hash IN (8637088342410109700)
                )
            ORDER BY
                adrevenue DESC
            LIMIT
                3
        )
) f0,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (-5713198883824118089)) 
ORDER BY adrevenue DESC LIMIT 3)) f1,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (2454218397564696334)) 
ORDER BY adrevenue DESC LIMIT 3)) f2,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (-1820666311870301227)) 
ORDER BY adrevenue DESC LIMIT 3)) f3,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab 
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (8644561162363758030, 1590051461067175528, -5053658049239510121, 7810904927140280516, -7009170756344001614,-5086883951133945964, -514832142673359269, 6127045034804176891, 1826441640885516856, 8381368794783220959)) 
ORDER BY adrevenue DESC LIMIT 3)) f4,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (6199526617341103713))
ORDER BY adrevenue DESC LIMIT 3)) f5,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (7740847646030491569, 7285727206792179080, 8629489941932462024, -1393525601299598534, 7418795809015032129,-7967245323559166905, 7322682162708365250)) 
ORDER BY adrevenue DESC LIMIT 3)) f6,
(SELECT LISTAGG(destinationurl, ', ') WITHIN GROUP (ORDER BY adrevenue DESC) FROM
(SELECT destinationurl, adrevenue FROM result_tab 
WHERE
searchword IN ( SELECT DISTINCT word FROM searchwords_tab 
WHERE word_hash IN (551453269330966873)) 
ORDER BY adrevenue DESC LIMIT 3)) f7;

-- query 21
SELECT
    uv.destinationurl AS uv_destinationurl,
    i.asname AS i_asname,
    a.operatingsystem AS a_operatingsystem,
    a.browser AS a_browser,
    COALESCE(SUM(uv.adrevenue), 0) AS uv_total_adrevenue,
    COUNT(DISTINCT uv.sourceip) AS uv_unique_visitors,
    NULLIF(SUM(uv.duration), 0)::decimal / NULLIF(COUNT(DISTINCT uv.sourceip), 0)::decimal AS uv_avg_duration_per_visitor,
    SUM(CASE WHEN uv.duration > 60 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT uv.sourceip), 0)::decimal AS uv_high_engagement_ratio,
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
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) >= 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            WHEN 'Date' = 'Date' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Complete' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            WHEN 'Date' = 'Date' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN (uv.visitdate + interval '1' day > CURRENT_DATE)
            WHEN 'Date' = 'Week' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('week', CURRENT_DATE) - interval '1 week' 
            WHEN 'Date' = 'Month' AND 'Off' = 'Partial' AND EXTRACT(HOUR FROM CURRENT_TIMESTAMP) < 9 THEN uv.visitdate >= date_trunc('month', CURRENT_DATE) - interval '1 month' 
            ELSE FALSE
        END) THEN 1 ELSE 0 END) = 1
GROUP BY uv_destinationurl, i.asname, a.operatingsystem, a.browser, r.pagerank
ORDER BY uv_total_adrevenue DESC
LIMIT 50;

-- query 22
SELECT
    uv.sourceip AS id,
    i.asname || ' - ' || a.browser AS group_name,
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
    SELECT 
        uv.sourceip AS c_id, 
        'config_sample'::VARCHAR AS scraping_conf_id, 
        uv.duration AS clicks,
        uv.visitdate AS insert_time, 
        sw.word AS keyword, 
        r.pagerank AS pos_o,
        uv.visitdate AS scrape_date, 
        'o'::VARCHAR AS serp_type, 
        a.browser AS site, 
        uv.destinationurl AS url,
        r.avgduration AS volume, 
        1.0::FLOAT AS cpc, 
        uv.countrycode AS country
    FROM uservisits uv
    JOIN searchwords sw ON uv.searchword = sw.word
    JOIN rankings r ON uv.destinationurl = r.pageurl
    JOIN agents a ON uv.useragent = a.agentname
    WHERE sw.word IN (SELECT keyword FROM c_curr_searchwords)
      AND uv.visitdate BETWEEN '2023-12-15'::DATE AND '2024-01-14'::DATE
      AND uv.sourceip = '45.125.176.154'
),
filtered_d AS (
    SELECT 
        fdp.country, 
        sw.word AS keyword, 
        '2022-12'::VARCHAR AS yearmonth, 
        5 AS d
    FROM searchwords sw
    JOIN filtered_dpd fdp ON sw.word = fdp.keyword
    WHERE sw.is_topic = true
),
filtered_i AS (
    SELECT 
        fdp.country, 
        sw.word AS keyword, 
        '2022-12'::VARCHAR AS yearmonth, 
        'informational'::VARCHAR AS primary_i
    FROM searchwords sw
    JOIN filtered_dpd fdp ON sw.word = fdp.keyword
    WHERE sw.is_topic = true
),
tags_by_c AS (
    SELECT 
        CAST('config_sample' AS VARCHAR) AS c_id, 
        sw.word AS keyword, 
        CAST('sample_tag' AS VARCHAR) AS "tag"
    FROM searchwords sw
    WHERE sw.word_id = 6813205734331865088
),
searchwords_with_all_filters AS (
    SELECT fdp.*
    FROM filtered_dpd fdp
),
filtered_tags AS (
    SELECT 
        fdp.scraping_conf_id, 
        fdp.keyword, 
        tb."tag",
        fdp.volume,
        MIN(CASE WHEN (fdp.site = 'google.com' OR fdp.site ILIKE '%.google.com%') THEN fdp.pos_o ELSE 100 END) AS top_pos,
        fdp.scrape_date, 
        SUM(fdp.clicks) AS clicks
    FROM tags_by_c tb
    LEFT JOIN searchwords_with_all_filters fdp ON fdp.keyword = tb.keyword
    GROUP BY fdp.scraping_conf_id, fdp.keyword, tb."tag", fdp.scrape_date, fdp.volume
),
weighted_rank_data AS (
    SELECT 
        t.scraping_conf_id, 
        t.keyword, 
        t."tag", 
        t.top_pos, 
        t.scrape_date, 
        t.volume,
        CASE WHEN COALESCE(t.volume, 0) != 0 THEN t.volume * t.top_pos END AS weighted_rank,
        CASE WHEN COALESCE(t.volume, 0) != 0 AND t.top_pos BETWEEN 1 AND 30 THEN t.volume * (31 - t.top_pos) ELSE 0 END AS weighted_visibility
    FROM filtered_tags t
),
clicks_sum AS (
    SELECT 
        "tag", 
        scrape_date, 
        SUM(clicks) AS clicks
    FROM filtered_tags
    GROUP BY "tag", scrape_date
),
volume_total AS (
    SELECT 
        "tag", 
        scrape_date, 
        SUM(volume) AS total_volume
    FROM weighted_rank_data
    GROUP BY "tag", scrape_date
),
metrics_per_day AS (
    SELECT 
        wrd."tag", 
        wrd.scrape_date, 
        COALESCE(cs.clicks, 0) AS clicks, 
        vt.total_volume,
        CASE 
            WHEN vt.total_volume = 0 THEN 100 
            ELSE SUM(wrd.weighted_rank) / vt.total_volume 
        END AS avg_weight_pos,
        CASE 
            WHEN vt.total_volume = 0 THEN 0 
            ELSE SUM(wrd.weighted_visibility) / (30 * vt.total_volume) 
        END AS visibility
    FROM weighted_rank_data wrd
    LEFT JOIN clicks_sum cs ON cs."tag" = wrd."tag" AND cs.scrape_date = wrd.scrape_date
    LEFT JOIN volume_total vt ON vt."tag" = wrd."tag" AND vt.scrape_date = wrd.scrape_date
    GROUP BY wrd."tag", wrd.scrape_date, cs.clicks, vt.total_volume
    ORDER BY wrd."tag", wrd.scrape_date
)
SELECT 
    m."tag", 
    MAX(m.total_volume) AS total_volume,
    LISTAGG(m.scrape_date::TEXT, ','), 
    LISTAGG(m.avg_weight_pos::TEXT, ','), 
    LISTAGG(m.clicks::TEXT, ','),
    LISTAGG(m.visibility::TEXT, ',')
FROM metrics_per_day m
GROUP BY m."tag";

-- query 24
WITH
  word_titles AS (
    SELECT
      word_id AS id,
      MAX(CASE WHEN firstseen IS NOT NULL THEN firstseen::TEXT END) AS word_title  -- Cast firstseen to TEXT
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
      LISTAGG(DISTINCT uv.languagecode, ',') AS languages,  -- Explicitly cast to TEXT
      LISTAGG(DISTINCT uv.searchword, ',') AS titles  -- Explicitly cast to VARCHAR::TEXT
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
      LISTAGG(uv.visitdate, ',') AS samples_ts,  -- Cast visitdate to TEXT
      LISTAGG(uv.duration, ',') AS samples_viewers,  -- Cast duration to TEXT
      LISTAGG(uv.searchword, ',') AS samples_title,  -- Explicit cast to VARCHAR::TEXT
      LISTAGG(sw.word_id, ',') AS samples_word_id,
      LISTAGG(gt.word_title, ',') AS samples_word_title
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
      LISTAGG(uv.searchword, ',')AS title_groups_title,  -- Cast searchword to VARCHAR::TEXT
      LISTAGG(uv.visitdate, ',') AS title_groups_first_seen,  -- Cast visitdate to TEXT
      LISTAGG(uv.duration, ',') AS title_groups_f1,  -- Cast duration to TEXT
      LISTAGG(uv.duration * uv.adrevenue, ',') AS title_groups_f2  -- Cast adrevenue to TEXT
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
      LISTAGG(sw.word_id, ',') AS word_groups_id,
      LISTAGG(uv.visitdate, ',') AS word_groups_first_seen,  -- Cast visitdate to TEXT
      LISTAGG(uv.duration, ',') AS word_groups_f1,  -- Cast duration to TEXT
      LISTAGG(uv.duration * uv.adrevenue, ',') AS word_groups_f2,  -- Cast adrevenue to TEXT
      LISTAGG(gt.word_title, ',') AS word_groups_title
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
      LISTAGG(sw.word_id, ',') AS word_title_groups_word_id,
      LISTAGG(uv.searchword, ',') AS word_title_groups_stream_title,
      LISTAGG(uv.visitdate, ',') AS word_title_groups_first_seen,
      LISTAGG(uv.duration, ',') AS word_title_groups_f1,
      LISTAGG(uv.duration * uv.adrevenue, ',') AS word_title_groups_f2,
      LISTAGG(uv.adrevenue, ',') AS word_title_groups_max_ccv
    FROM
      uservisits uv
      JOIN searchwords sw ON uv.searchword = sw.word
    WHERE
      uv.visitdate BETWEEN '2023-07-12' AND '2023-07-14'
    GROUP BY
      uv.sourceip
  )
SELECT
  b.*,
  s.*,
  gt.*,
  gg.*,
  ggt.*
FROM
  base b
  LEFT JOIN samples s ON s.stream_id = b.stream_id
  LEFT JOIN group_title gt ON gt.stream_id = b.stream_id
  LEFT JOIN group_word gg ON gg.stream_id = b.stream_id
  LEFT JOIN group_word_and_title ggt ON ggt.stream_id = b.stream_id
ORDER BY
  b.started_at ASC
LIMIT 100;

-- query 25
WITH
  base_metrics AS (
    SELECT
      uv.countrycode AS country,
      sw.word AS searchword,
      COUNT(uv.sourceip) AS clicks,
      SUM(uv.duration) AS volume,
      (SUM(uv.duration) - AVG(SUM(uv.duration)) OVER (PARTITION BY sw.word)) / AVG(SUM(uv.duration)) OVER (PARTITION BY sw.word) AS volume_trend,
      MAX(uv.countrycode) AS top_country,
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
      AND NOT (
        position('pattern1|text2|word3' in lower(j.searchword)) > 0
      )
  )

SELECT
  *,
  (SELECT COUNT(*) FROM related) AS result_count,
  (SELECT MAX(score) FROM related) AS max_score
FROM
  related
ORDER BY
  score DESC
LIMIT 400 OFFSET 0;