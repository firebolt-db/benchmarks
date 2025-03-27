# 📊 Benchmark Report: FireScale

This file contains the main results of the FireScale benchmark. For other results, see the other
markdown files in this folder:

* [Concurrency results](./concurrency.md)
* [First (cold) run results](./first_run.md)
* [Firebolt on TPCH](./TPCH-100gb.csv)

The following sections contain each benchmark query, execution times across configurations, and rankings.
🥇 = Fastest configuration, 🥈 = 2nd fastest, 🥉 = 3rd fastest

---

## 🔎 Per-Query Details

### 📄 Query 1

<details>
<summary>Click to view SQL</summary>

```sql
SELECT visitdate, sourceip, adrevenue 
FROM uservisits 
WHERE (visitdate BETWEEN '1982-10-05' AND '1982-10-19')
AND sourceip IN ('71.66.154.126')
AND countrycode = 'EGY';
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Redshift | (4 x ra3.4xlarge) | 0.0295 🥇 |
| Firebolt | (1 x L) | 0.0338 🥈 |
| Redshift | (7 x ra3.4xlarge) | 0.0351 🥉 |
| Firebolt | (1 x XL) | 0.0391 |
| Firebolt | (1 x M) | 0.0402 |
| Redshift | (2 x ra3.4xlarge) | 0.048 |
| Firebolt | (1 x S) | 0.0626 |
| Snowflake | (M) | 0.111 |
| Snowflake | (S) | 0.126 |
| Snowflake | (L) | 0.127 |
| Snowflake | (XL) | 0.144 |
| Snowflake | (XS) | 0.246 |
| BigQuery |  | 0.986 |

### 📄 Query 2

<details>
<summary>Click to view SQL</summary>

```sql
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
            where sourceip in ('99.99.96.94')
            and countrycode < 'zzz'
            and visitdate between '1980-02-17' and '1980-02-22'
            and useragent = 'Nddrtrgdepophmckxlcp/2.8'
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
            where sourceip in ('1.0.108.16')
            and countrycode < 'zzz'
            and visitdate between '1980-02-17' and '1980-02-22'
            and useragent = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)'
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
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0511 🥇 |
| Firebolt | (1 x M) | 0.0532 🥈 |
| Firebolt | (1 x S) | 0.0616 🥉 |
| Firebolt | (1 x XL) | 0.0622 |
| Redshift | (4 x ra3.4xlarge) | 0.099 |
| Redshift | (7 x ra3.4xlarge) | 0.101 |
| Redshift | (2 x ra3.4xlarge) | 0.154 |
| Snowflake | (XS) | 0.165 |
| Snowflake | (S) | 0.17 |
| Snowflake | (M) | 0.185 |
| Snowflake | (L) | 0.186 |
| Snowflake | (XL) | 0.189 |
| BigQuery |  | 0.845 |

### 📄 Query 3

<details>
<summary>Click to view SQL</summary>

```sql
SELECT languagecode,
    MAX(visitdate) AS visitdate,
    ARRAY_JOIN(ARRAY_AGG(countrycode), ',') AS countrycode
FROM uservisits
WHERE sourceip = '23.232.221.175' and visitdate between '1982-10-05' and '1982-10-06'
GROUP BY languagecode;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0249 🥇 |
| Firebolt | (1 x S) | 0.0271 🥈 |
| Firebolt | (1 x XL) | 0.0283 🥉 |
| Firebolt | (1 x M) | 0.0303 |
| Redshift | (4 x ra3.4xlarge) | 0.0316 |
| Redshift | (7 x ra3.4xlarge) | 0.0351 |
| Redshift | (2 x ra3.4xlarge) | 0.054 |
| Snowflake | (XS) | 0.092 |
| Snowflake | (S) | 0.107 |
| Snowflake | (L) | 0.114 |
| Snowflake | (XL) | 0.115 |
| Snowflake | (M) | 0.125 |
| BigQuery |  | 0.645 |

### 📄 Query 4

<details>
<summary>Click to view SQL</summary>

```sql
SELECT *
FROM uservisits
WHERE sourceip = '222.63.178.183' and visitdate between '1982-10-05' and '1982-10-06';
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x S) | 0.0282 🥇 |
| Firebolt | (1 x M) | 0.0288 🥈 |
| Firebolt | (1 x L) | 0.0288 🥉 |
| Redshift | (4 x ra3.4xlarge) | 0.0289 |
| Firebolt | (1 x XL) | 0.0327 |
| Redshift | (7 x ra3.4xlarge) | 0.0329 |
| Redshift | (2 x ra3.4xlarge) | 0.0482 |
| Snowflake | (XS) | 0.0924 |
| Snowflake | (M) | 0.102 |
| Snowflake | (S) | 0.103 |
| Snowflake | (L) | 0.103 |
| Snowflake | (XL) | 0.107 |
| BigQuery |  | 0.767 |

### 📄 Query 5

<details>
<summary>Click to view SQL</summary>

```sql
WITH filtered_uservisits AS( SELECT *     
  FROM uservisits     
  WHERE visitdate between '1970-01-01' and '1970-01-02') 
  SELECT allowed_records.destinationurl, COUNT(*) OVER () as total_uservisits_count 
  FROM filtered_uservisits JOIN ( SELECT destinationurl 
                                FROM filtered_uservisits 
                                ORDER BY duration DESC LIMIT 100 ) AS allowed_records ON allowed_records.destinationurl = filtered_uservisits.destinationurl 
  ORDER BY adrevenue desc LIMIT 20 OFFSET 0;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0459 🥇 |
| Firebolt | (1 x XL) | 0.0491 🥈 |
| Firebolt | (1 x M) | 0.0506 🥉 |
| Firebolt | (1 x S) | 0.0574 |
| Redshift | (4 x ra3.4xlarge) | 0.0647 |
| Redshift | (7 x ra3.4xlarge) | 0.0769 |
| Redshift | (2 x ra3.4xlarge) | 0.109 |
| Snowflake | (S) | 0.186 |
| Snowflake | (XS) | 0.188 |
| Snowflake | (L) | 0.214 |
| Snowflake | (M) | 0.239 |
| Snowflake | (XL) | 0.247 |
| BigQuery |  | 1.37 |

### 📄 Query 6

<details>
<summary>Click to view SQL</summary>

```sql
SELECT COUNT(*) as c FROM uservisits WHERE sourceip = '52.102.108.201' and visitdate = '1971-09-03';
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0193 🥇 |
| Firebolt | (1 x M) | 0.0206 🥈 |
| Firebolt | (1 x S) | 0.0212 🥉 |
| Redshift | (4 x ra3.4xlarge) | 0.0215 |
| Firebolt | (1 x XL) | 0.0247 |
| Redshift | (7 x ra3.4xlarge) | 0.0265 |
| Redshift | (2 x ra3.4xlarge) | 0.0549 |
| Snowflake | (XS) | 0.092 |
| Snowflake | (S) | 0.101 |
| Snowflake | (M) | 0.111 |
| Snowflake | (L) | 0.115 |
| Snowflake | (XL) | 0.117 |
| BigQuery |  | 0.625 |

### 📄 Query 7

<details>
<summary>Click to view SQL</summary>

```sql
SELECT max(visitdate) as latest_visit
FROM uservisits
WHERE (visitdate >= '1971-09-03' AND visitdate <= DATE_ADD('DAY', 1, '1971-09-03'));
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0211 🥇 |
| Redshift | (4 x ra3.4xlarge) | 0.0214 🥈 |
| Firebolt | (1 x M) | 0.0227 🥉 |
| Firebolt | (1 x S) | 0.0248 |
| Redshift | (7 x ra3.4xlarge) | 0.0283 |
| Firebolt | (1 x XL) | 0.0286 |
| Redshift | (2 x ra3.4xlarge) | 0.0398 |
| Snowflake | (XS) | 0.0791 |
| Snowflake | (XL) | 0.0895 |
| Snowflake | (S) | 0.0913 |
| Snowflake | (L) | 0.0932 |
| Snowflake | (M) | 0.0968 |
| BigQuery |  | 0.521 |

### 📄 Query 8

<details>
<summary>Click to view SQL</summary>

```sql
SELECT date_trunc('month', visitdate) as year_month_day,
COALESCE(SUM(duration), 0) as installs,
COALESCE(SUM(length(searchword)), 0) as billingCost,
SUM(CASE WHEN adrevenue <= 1.5 THEN duration ELSE 0 END) as revenueD7
FROM uservisits
WHERE (visitdate >= '1971-09-03' AND visitdate <= DATE_ADD('DAY', 1, '1971-09-03'))
        AND languagecode IN ('PER-ES','ARG-ES','SGP-ZH','CRI-ES','NZL-EN','GRC-DE','PER-ES','SVN-SL')
GROUP BY 1
ORDER BY 1;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0347 🥇 |
| Firebolt | (1 x M) | 0.0383 🥈 |
| Firebolt | (1 x XL) | 0.0447 🥉 |
| Firebolt | (1 x S) | 0.0462 |
| Redshift | (4 x ra3.4xlarge) | 0.054 |
| Redshift | (7 x ra3.4xlarge) | 0.0596 |
| Redshift | (2 x ra3.4xlarge) | 0.0917 |
| Snowflake | (M) | 0.1 |
| Snowflake | (XS) | 0.106 |
| Snowflake | (L) | 0.107 |
| Snowflake | (XL) | 0.11 |
| Snowflake | (S) | 0.125 |
| BigQuery |  | 0.628 |

### 📄 Query 9

<details>
<summary>Click to view SQL</summary>

```sql
SELECT destinationurl
from uservisits
where adrevenue between 0.15833622633632996 and 0.9281767108678773 and visitdate between '1970-01-01' and '1970-01-07'
group by destinationurl having count(*) > 40;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Redshift | (7 x ra3.4xlarge) | 0.0994 🥇 |
| Firebolt | (1 x L) | 0.116 🥈 |
| Firebolt | (1 x XL) | 0.117 🥉 |
| Firebolt | (1 x M) | 0.192 |
| Redshift | (4 x ra3.4xlarge) | 0.212 |
| Snowflake | (M) | 0.225 |
| Snowflake | (XL) | 0.253 |
| Snowflake | (L) | 0.263 |
| Redshift | (2 x ra3.4xlarge) | 0.288 |
| Firebolt | (1 x S) | 0.326 |
| Snowflake | (XS) | 0.403 |
| Snowflake | (S) | 0.451 |
| BigQuery |  | 3.04 |

### 📄 Query 10

<details>
<summary>Click to view SQL</summary>

```sql
with busiest_days as (
  select visitdate, count(*)
  from uservisits
  group by 1
  order by 2 desc
  limit 91
)
select countrycode, avg(length(searchword))
from uservisits
where visitdate in (select visitdate from busiest_days)
group by countrycode;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.986 🥇 |
| Snowflake | (XL) | 1.15 🥈 |
| Firebolt | (1 x L) | 1.76 🥉 |
| Snowflake | (L) | 1.81 |
| Redshift | (7 x ra3.4xlarge) | 1.98 |
| Redshift | (4 x ra3.4xlarge) | 2 |
| BigQuery |  | 2.24 |
| Snowflake | (M) | 3.03 |
| Firebolt | (1 x M) | 3.23 |
| Redshift | (2 x ra3.4xlarge) | 5.49 |
| Snowflake | (S) | 5.69 |
| Firebolt | (1 x S) | 6.36 |
| Snowflake | (XS) | 11.2 |

### 📄 Query 11

<details>
<summary>Click to view SQL</summary>

```sql
SELECT searchword, useragent, languagecode
from uservisits 
where countrycode = 'PAN'
  and visitdate = '1971-09-03'
  and searchword in ('sxmtgekwngjwyjerk','jamyfanaoacldwi','hucii','xrlxwsikfsbuf','wubrrjursvtqteia','jfkjvramnrvuyp')
Limit 65;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0279 🥇 |
| Firebolt | (1 x M) | 0.0331 🥈 |
| Firebolt | (1 x XL) | 0.0337 🥉 |
| Firebolt | (1 x S) | 0.0429 |
| Redshift | (4 x ra3.4xlarge) | 0.0693 |
| Redshift | (7 x ra3.4xlarge) | 0.0729 |
| Snowflake | (L) | 0.0753 |
| Snowflake | (M) | 0.0875 |
| Snowflake | (S) | 0.0886 |
| Snowflake | (XL) | 0.0966 |
| Redshift | (2 x ra3.4xlarge) | 0.0992 |
| Snowflake | (XS) | 0.118 |
| BigQuery |  | 0.522 |

### 📄 Query 12

<details>
<summary>Click to view SQL</summary>

```sql
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
  visitdate >= '1998-02-02' and visitdate <= '1998-03-04' AND
  countrycode in ( 'VEN','IND','BIH','HUN','SAU','MLT','DZA','PHL','JOR','IRL') AND
  languagecode in ( 'VEN-ES','IND-HI','BIH-SR','HUN-HU','SAU-AR','MLT-MT','DZA-AR','PHL-EN','JOR-AR','IRL-GA') AND
  useragent in ( 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)','Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)','Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)','Mozilla/5.0 (iPhone; U; CPU like Mac OS X)AppleWebKit/420.1 (KHTML like Gecko) Version/3.0 Mobile/4A93Safari/419.3','Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)','Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)','Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)','Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2)','Vtnpeyaoljvtht/7.3','Mozilla/5.0 (Windows; U; Windows NT 5.2) AppleWebKit/525.13 (KHTML like Gecko) Chrome/xxx')
GROUP BY 1, 2;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.0934 🥇 |
| Firebolt | (1 x L) | 0.118 🥈 |
| Snowflake | (XL) | 0.134 🥉 |
| Snowflake | (M) | 0.149 |
| Snowflake | (L) | 0.155 |
| Firebolt | (1 x M) | 0.185 |
| Snowflake | (S) | 0.192 |
| Redshift | (4 x ra3.4xlarge) | 0.212 |
| Snowflake | (XS) | 0.213 |
| Redshift | (7 x ra3.4xlarge) | 0.216 |
| Redshift | (2 x ra3.4xlarge) | 0.309 |
| Firebolt | (1 x S) | 0.341 |
| BigQuery |  | 0.842 |

### 📄 Query 13

<details>
<summary>Click to view SQL</summary>

```sql
WITH                 
                CTE1 AS 
                ( 
                    SELECT languagecode FROM uservisits
WHERE uservisits.countrycode = 'TUN'
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
                    uservisits.visitdate between '1982-10-05'::DATE and '1982-11-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') AND uservisits.searchword IN ('lprrwdsxemjlpms') 
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
                    uservisits.visitdate between '1982-10-05'::DATE and '1982-11-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') AND uservisits.searchword IN ('lprrwdsxemjlpms') 
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
                    uservisits.visitdate between '1982-10-05'::DATE and '1982-11-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
                    AND uservisits.searchword IN ('lprrwdsxemjlpms') 
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
                    uservisits.visitdate between '1982-10-05'::DATE and '1982-11-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
                    uservisits.visitdate between '1982-12-05'::DATE and '1983-01-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') AND languagecode NOT IN ( SELECT * FROM CTE1 ) 
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
                    uservisits.visitdate between '1983-03-05'::DATE and '1983-04-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
                    uservisits.visitdate between '1983-03-05'::DATE and '1983-04-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
                    uservisits.visitdate between '1983-03-05'::DATE and '1983-04-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
                    uservisits.visitdate between '1983-03-05'::DATE and '1983-04-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
                    uservisits.visitdate between '1983-03-05'::DATE and '1983-04-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
                    uservisits.visitdate between '1983-03-05'::DATE and '1983-04-05'::DATE AND
                    uservisits.countrycode IN ('TUN','URY','MKD') 
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
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.869 🥇 |
| Firebolt | (1 x L) | 1.09 🥈 |
| Snowflake | (L) | 1.7 🥉 |
| Snowflake | (XL) | 1.77 |
| Snowflake | (M) | 1.78 |
| Firebolt | (1 x M) | 1.8 |
| Snowflake | (S) | 1.95 |
| Snowflake | (XS) | 2.67 |
| Firebolt | (1 x S) | 3 |
| Redshift | (7 x ra3.4xlarge) | 3.39 |
| Redshift | (4 x ra3.4xlarge) | 3.42 |
| Redshift | (2 x ra3.4xlarge) | 5.24 |
| BigQuery |  | 10.9 |

### 📄 Query 14

<details>
<summary>Click to view SQL</summary>

```sql
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
  uv.visitdate >= '1971-09-03' AND uv.visitdate < '1971-10-04'
    AND coalesce(uv.countrycode, '') = 'MYS'
    AND (
        CASE
            WHEN uv.countrycode = '' AND uv.sourceip IS NOT NULL THEN 'Populated'
            WHEN uv.countrycode = '' THEN 'Not Populated'
            ELSE 'Populated'
        END = 'Populated'
    )
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
     AND REGEXP_LIKE(a.browser, 'Safari')
GROUP BY
    1
HAVING COALESCE(COUNT(DISTINCT uv.sourceip), 0) > 0
ORDER BY
    2 DESC
FETCH NEXT 50 ROWS ONLY;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.138 🥇 |
| Firebolt | (1 x L) | 0.169 🥈 |
| Firebolt | (1 x M) | 0.25 🥉 |
| Firebolt | (1 x S) | 0.379 |
| Snowflake | (XL) | 0.775 |
| Snowflake | (L) | 1.1 |
| Snowflake | (M) | 1.65 |
| Snowflake | (S) | 2.86 |
| Redshift | (4 x ra3.4xlarge) | 3.42 |
| Redshift | (7 x ra3.4xlarge) | 3.45 |
| BigQuery |  | 5.26 |
| Snowflake | (XS) | 5.44 |
| Redshift | (2 x ra3.4xlarge) | 18.9 |

### 📄 Query 15

<details>
<summary>Click to view SQL</summary>

```sql
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
          WHERE uv.sourceip LIKE '222%' and visitdate between '1982-10-05' and '1982-10-06' 
          GROUP BY 1, 2
        ) ww
      ) bb WHERE z__pivot_col_rank <= 10000
    ) aa
  ) xx
) zz
WHERE (z__pivot_col_rank <= 50 OR z__is_highest_ranked_cell = 1) AND (z___pivot_row_rank <= 500 OR z__pivot_col_ordering = 1)
ORDER BY z___pivot_row_rank;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0499 🥇 |
| Firebolt | (1 x M) | 0.0505 🥈 |
| Firebolt | (1 x S) | 0.054 🥉 |
| Firebolt | (1 x XL) | 0.0575 |
| Redshift | (4 x ra3.4xlarge) | 0.132 |
| Redshift | (7 x ra3.4xlarge) | 0.136 |
| Redshift | (2 x ra3.4xlarge) | 0.233 |
| Snowflake | (XL) | 0.249 |
| Snowflake | (S) | 0.261 |
| Snowflake | (M) | 0.264 |
| Snowflake | (L) | 0.275 |
| Snowflake | (XS) | 0.336 |
| BigQuery |  | 2.34 |

### 📄 Query 16

<details>
<summary>Click to view SQL</summary>

```sql
SELECT r.*, v.visitdate, v.adrevenue
FROM uservisits v inner join rankings r on v.destinationurl = r.pageurl
WHERE sourceip ='159.220.2.32' and visitdate between '1985-01-19' and '1985-01-25';
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x S) | 0.0282 🥇 |
| Firebolt | (1 x L) | 0.029 🥈 |
| Firebolt | (1 x M) | 0.0305 🥉 |
| Firebolt | (1 x XL) | 0.0396 |
| Redshift | (4 x ra3.4xlarge) | 0.04 |
| Redshift | (7 x ra3.4xlarge) | 0.0451 |
| Redshift | (2 x ra3.4xlarge) | 0.0791 |
| Snowflake | (S) | 0.164 |
| Snowflake | (M) | 0.189 |
| Snowflake | (XL) | 0.191 |
| Snowflake | (L) | 0.206 |
| Snowflake | (XS) | 0.213 |
| BigQuery |  | 0.918 |

### 📄 Query 17

<details>
<summary>Click to view SQL</summary>

```sql
SELECT destinationurl, COUNT(*) AS visit_count FROM UserVisits WHERE (countrycode ='ESP' or countrycode = 'RUS') 
 AND EXTRACT(YEAR FROM visitDate) = 2012 AND EXTRACT(MONTH FROM visitDate) = 4 
 GROUP BY destinationurl LIMIT 100;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Redshift | (4 x ra3.4xlarge) | 0.0821 🥇 |
| Redshift | (7 x ra3.4xlarge) | 0.0836 🥈 |
| Firebolt | (1 x XL) | 0.0926 🥉 |
| Firebolt | (1 x L) | 0.112 |
| Firebolt | (1 x M) | 0.171 |
| Redshift | (2 x ra3.4xlarge) | 0.179 |
| Snowflake | (L) | 0.219 |
| Snowflake | (XL) | 0.228 |
| Snowflake | (M) | 0.244 |
| Firebolt | (1 x S) | 0.282 |
| Snowflake | (S) | 0.288 |
| Snowflake | (XS) | 0.4 |
| BigQuery |  | 1.01 |

### 📄 Query 18

<details>
<summary>Click to view SQL</summary>

```sql
SELECT destinationurl, sum(adrevenue) as adrevenues
from uservisits
WHERE searchword = 'rumclqkuxilymf'
    and countrycode = 'NLD'
    and visitdate BETWEEN '1997-12-25' AND '1997-12-30'
    and REGEXP_LIKE(destinationurl,'^aaav')
group by destinationurl
order by adrevenues DESC, destinationurl
LIMIT 20000;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.0398 🥇 |
| Firebolt | (1 x M) | 0.0465 🥈 |
| Firebolt | (1 x XL) | 0.0526 🥉 |
| Firebolt | (1 x S) | 0.0621 |
| Snowflake | (S) | 0.11 |
| Snowflake | (XL) | 0.113 |
| Snowflake | (M) | 0.126 |
| Snowflake | (L) | 0.131 |
| Snowflake | (XS) | 0.131 |
| Redshift | (4 x ra3.4xlarge) | 0.22 |
| Redshift | (7 x ra3.4xlarge) | 0.229 |
| Redshift | (2 x ra3.4xlarge) | 0.363 |
| BigQuery |  | 0.674 |

### 📄 Query 19

<details>
<summary>Click to view SQL</summary>

```sql
WITH CTE1
AS
(
SELECT  
  searchword AS searchword,
		B.languagecode,
		SUM(B.duration) AS sum_duration
FROM uservisits B
INNER JOIN agents  ON   B.useragent = agents.agentname 
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND B.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
AND B.countrycode  IN ('MNE')
AND B.sourceip IN ('193.40.40.164')
GROUP BY searchword, B.languagecode
),

CTE2
AS
(
SELECT DISTINCT A.languagecode  
FROM uservisits A 
INNER JOIN agents 
ON   A.useragent = agentname 
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
AND A.sourceip IN ('193.40.40.164')
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
AND A.countrycode  IN ('MNE')
AND A.sourceip IN ('193.40.40.164')
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1') 
AND B.countrycode  IN ('MNE')
AND B.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.countrycode IN('MNE')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.countrycode  IN ('MNE')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1') 
AND B.countrycode  IN ('MNE')
AND B.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE
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

WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.countrycode  IN ('MNE')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE  
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND B.countrycode  IN ('MNE')
AND B.sourceip IN ('193.40.40.164')
AND B.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE  
GROUP BY searchword, B.languagecode
),

CTE11
AS
(
SELECT DISTINCT A.languagecode  
FROM uservisits A
INNER JOIN agents 
ON   A.useragent = agentname 
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.sourceip IN ('193.40.40.164')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE  
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
WHERE agents.operatingsystem = 'Windows 10' 
AND agents.devicearch = 'x64'
AND agents.browser IN ('Internet Explorer', 'Qbtuhtunyhwcqkjktthkymsxb/1.', 'Adabkjshehkwvvbdmahdwoku/5.1')
AND A.countrycode  IN ('MNE')
AND A.sourceip IN ('193.40.40.164')
AND A.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE    
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
  AND C2.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE  
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
AND C2.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE    
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
AND C2.visitdate between '1984-03-21'::DATE and '1984-03-23'::DATE    
GROUP BY ALL
)

SELECT searchword,where_duration,SUM(sum_duration_DATA) FROM (

SELECT searchword AS searchword,
where_duration AS where_duration,
(C1.sum_duration_DATA) AS sum_duration_DATA
FROM CTE13 AS C1
WHERE  0<>(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('193.40.40.164'))

UNION ALL
SELECT searchword AS searchword,
where_duration AS where_duration,
(C2.sum_duration_DATA) AS sum_duration_DATA
FROM CTE16 AS C2
WHERE  0<>(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('193.40.40.164'))

UNION ALL
SELECT searchword AS searchword,
where_duration AS where_duration,
(C3.sum_duration_DATA) AS sum_duration_DATA
FROM CTE14 AS C3
WHERE  0=(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('193.40.40.164'))

UNION ALL
SELECT searchword AS searchword,
where_duration AS where_duration,
(C4.sum_duration_DATA) AS sum_duration_DATA
FROM CTE15 AS C4
WHERE  0=(SELECT COUNT(ip) FROM ipaddresses WHERE ip IN ('193.40.40.164'))

)
GROUP BY searchword,where_duration;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.676 🥇 |
| Firebolt | (1 x XL) | 0.832 🥈 |
| Firebolt | (1 x M) | 0.855 🥉 |
| Firebolt | (1 x S) | 0.935 |
| Snowflake | (L) | 2 |
| Snowflake | (M) | 2.08 |
| Snowflake | (XL) | 2.14 |
| Snowflake | (S) | 2.25 |
| Snowflake | (XS) | 2.83 |
| BigQuery |  | 3.35 |
| Redshift | (7 x ra3.4xlarge) | 11.3 |
| Redshift | (4 x ra3.4xlarge) | 11.4 |
| Redshift | (2 x ra3.4xlarge) | 18.8 |

### 📄 Query 20

<details>
<summary>Click to view SQL</summary>

```sql
With origin_tab as (
    select
        *
    from
        uservisits
    where
  		visitdate between '1996-01-13'::DATE and '1996-01-14'::DATE
        and countrycode in ('ARG', 'SWE')
        and regexp_like(destinationurl, '.*(ad|b$)')
        and adrevenue > 0.9
),
searchwords_tab as (
    select * from searchwords where word like 'dmj%'
    union all
    select * from searchwords where word like 'oaw%'
    union all
    select * from searchwords where word like 'sqy%'
    union all
    select * from searchwords where word like 'uiq%'
    union all
    select * from searchwords where word like 'ypc%'
),
result_tab as (
    select *
    from origin_tab
    where visitdate between '1995-12-29'::DATE and '1996-03-13'::DATE
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
                        word_hash in (-7415420274510428330)
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
where word_hash in (-8980519242285124908)) 
order by adrevenue desc limit 3)) f1
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (7899244578289190280)) 
order by adrevenue desc limit 3)) f2
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (-6034021915782578368)) 
order by adrevenue desc limit 3)) f3
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (-2474214877239986428,2108235117380421554,1933492463231786852,6511871038920919944,827423760198925133,-3402740342860750120,6367591589524276899,-7354092148153388744,-5091813435214241015,-3648440944875687797)) 
order by adrevenue desc limit 3)) f4
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (-3270318827080561768)) 
order by adrevenue desc limit 3)) f5
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (760998907509127183,-1705571121037205547,-5274470558381209768,1187362410747005146,6881555994214033696,6608489628838647222,2608579498325714199)) 
order by adrevenue desc limit 3)) f6
,
(select ARRAY_AGG(destinationurl) from
(select destinationurl from result_tab
where
searchword in ( select distinct word from searchwords_tab 
where word_hash in (3536249655543172992)) 
order by adrevenue desc limit 3)) f7;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x L) | 0.525 🥇 |
| Firebolt | (1 x M) | 0.549 🥈 |
| Firebolt | (1 x S) | 0.762 🥉 |
| Firebolt | (1 x XL) | 0.929 |
| Redshift | (4 x ra3.4xlarge) | 1.04 |
| Redshift | (7 x ra3.4xlarge) | 1.05 |
| Snowflake | (S) | 1.08 |
| Snowflake | (M) | 1.11 |
| Snowflake | (L) | 1.13 |
| Snowflake | (XL) | 1.22 |
| Snowflake | (XS) | 1.31 |
| Redshift | (2 x ra3.4xlarge) | 1.5 |
| BigQuery |  | 1.73 |

### 📄 Query 21

<details>
<summary>Click to view SQL</summary>

```sql
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
    WHERE visitdate >= '1988-05-20' AND visitdate < '1988-06-19' and countrycode = 'BEL'
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
WHERE uv.countrycode = 'BEL' AND a.operatingsystem = 'Windows 10'
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
FETCH NEXT 50 ROWS ONLY;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x S) | 0.0682 🥇 |
| Firebolt | (1 x M) | 0.0694 🥈 |
| Firebolt | (1 x L) | 0.0812 🥉 |
| Firebolt | (1 x XL) | 0.0812 |
| Snowflake | (S) | 0.394 |
| Snowflake | (L) | 0.396 |
| Snowflake | (M) | 0.399 |
| Snowflake | (XL) | 0.418 |
| Snowflake | (XS) | 0.431 |
| Redshift | (7 x ra3.4xlarge) | 4.88 |
| Redshift | (4 x ra3.4xlarge) | 4.88 |
| Redshift | (2 x ra3.4xlarge) | 6.89 |
| BigQuery |  | 7.2 |

### 📄 Query 22

<details>
<summary>Click to view SQL</summary>

```sql
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
WHERE uv.visitdate >= '2000-03-04' AND uv.visitdate < '2000-03-07'
    AND a.operatingsystem = 'macOS'
GROUP BY 1, 2
ORDER BY f1 DESC
LIMIT 50;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.383 🥇 |
| Firebolt | (1 x L) | 0.49 🥈 |
| Firebolt | (1 x M) | 0.744 🥉 |
| Snowflake | (XL) | 0.763 |
| Snowflake | (M) | 0.901 |
| Snowflake | (L) | 0.987 |
| Snowflake | (S) | 1.22 |
| Firebolt | (1 x S) | 1.29 |
| Snowflake | (XS) | 1.46 |
| BigQuery |  | 3.48 |
| Redshift | (7 x ra3.4xlarge) | 4.38 |
| Redshift | (4 x ra3.4xlarge) | 4.4 |
| Redshift | (2 x ra3.4xlarge) | 6.26 |

### 📄 Query 23

<details>
<summary>Click to view SQL</summary>

```sql
WITH c_curr_searchwords AS materialized (
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
    AND uv.visitdate BETWEEN '1970-01-01' AND '1970-01-31' and uv.sourceip = '135.186.62.229'
),
filtered_d AS (
    SELECT fdp.country, sw.word AS keyword, '1969-01' AS yearmonth, 5 AS d
    FROM searchwords sw
    JOIN filtered_dpd fdp ON sw.word = fdp.keyword
    WHERE sw.is_topic = true
),
filtered_i AS (
    SELECT fdp.country, sw.word AS keyword, '1969-01' AS yearmonth, 'informational' AS primary_i
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
           MIN(CASE WHEN (site = 'google.com' OR site ILIKE '%.google.com%') THEN pos_o ELSE 100 END) AS top_pos,
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
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x S) | 0.116 🥇 |
| Firebolt | (1 x M) | 0.122 🥈 |
| Firebolt | (1 x L) | 0.152 🥉 |
| Firebolt | (1 x XL) | 0.168 |
| Snowflake | (S) | 0.501 |
| Snowflake | (M) | 0.515 |
| Snowflake | (L) | 0.53 |
| Redshift | (7 x ra3.4xlarge) | 0.55 |
| Redshift | (4 x ra3.4xlarge) | 0.563 |
| Snowflake | (XL) | 0.58 |
| Snowflake | (XS) | 0.637 |
| Redshift | (2 x ra3.4xlarge) | 0.851 |
| BigQuery |  | 2.02 |

### 📄 Query 24

<details>
<summary>Click to view SQL</summary>

```sql
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
      uv.visitdate BETWEEN '2000-03-04' AND '2000-03-06'
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
      uv.visitdate BETWEEN '2000-03-04' AND '2000-03-06'
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
      uv.visitdate BETWEEN '2000-03-04' AND '2000-03-06'
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
      uv.visitdate BETWEEN '2000-03-04' AND '2000-03-06'
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
      uv.visitdate BETWEEN '2000-03-04' AND '2000-03-06'
    GROUP BY
      uv.sourceip
  )
SELECT
  b.*,
  s.* EXCLUDE(stream_id),
  gt.* EXCLUDE(stream_id),
  gg.* EXCLUDE(stream_id),
  ggt.* EXCLUDE(stream_id)
FROM
  base b
  LEFT JOIN samples s ON s.stream_id = b.stream_id
  LEFT JOIN group_title gt ON gt.stream_id = b.stream_id
  LEFT JOIN group_word gg ON gg.stream_id = b.stream_id
  LEFT JOIN group_word_and_title ggt ON ggt.stream_id = b.stream_id
ORDER BY
  b.started_at ASC
limit 100;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.282 🥇 |
| Firebolt | (1 x L) | 0.369 🥈 |
| Firebolt | (1 x M) | 0.562 🥉 |
| Firebolt | (1 x S) | 1.03 |
| Redshift | (7 x ra3.4xlarge) | 2.81 |
| Redshift | (4 x ra3.4xlarge) | 2.87 |
| Redshift | (2 x ra3.4xlarge) | 5.37 |
| Snowflake | (XL) | 5.8 |
| Snowflake | (L) | 7.42 |
| Snowflake | (M) | 9.51 |
| BigQuery |  | 9.79 |
| Snowflake | (S) | 16.4 |
| Snowflake | (XS) | 32.1 |

### 📄 Query 25

<details>
<summary>Click to view SQL</summary>

```sql
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
      uv.countrycode = 'SYR'
      AND uv.visitdate >= DATE '1979-07-25'
      AND uv.visitdate < DATE '1979-07-27'
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
      uv.countrycode = 'SYR'
      AND uv.visitdate >= DATE '1979-07-25'
      AND uv.visitdate < DATE '1979-08-24'
  ),

  original_count AS (
    SELECT
      SUM(total_sites) AS original_total
    FROM
      base_metrics
    WHERE
      searchword = 'obnprqyuhcev'
  ),

  site_intersection AS (
    SELECT
      b.searchword,
      COUNT(b.site) AS intersection
    FROM
      base_site b
    WHERE
      b.site IN (SELECT site FROM base_site WHERE searchword = 'obnprqyuhcev')
    GROUP BY
      b.searchword
  ),

  joined AS materialized (
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
      kwm.searchword IN (SELECT searchword FROM site_intersection UNION ALL SELECT 'obnprqyuhcev')
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
      j.searchword != 'some-value-that-not-exist'
      AND NOT REGEXP_LIKE(LOWER(j.searchword), 'pattern1|text2|word3')
  )

SELECT
  *,
  (SELECT COUNT(*) FROM related) AS result_count,
  (SELECT MAX(score) FROM related) AS max_score
FROM related
ORDER BY score DESC
LIMIT 400 OFFSET 0;
```
</details>

#### 🧪 Execution Times (sorted by time)

| Platform | Configuration | Execution Time (s) |
|----------|----------------|--------------------|
| Firebolt | (1 x XL) | 0.54 🥇 |
| Firebolt | (1 x L) | 0.572 🥈 |
| Firebolt | (1 x M) | 0.835 🥉 |
| Redshift | (4 x ra3.4xlarge) | 1.24 |
| Redshift | (7 x ra3.4xlarge) | 1.31 |
| Snowflake | (XL) | 1.33 |
| Firebolt | (1 x S) | 1.36 |
| Snowflake | (L) | 1.43 |
| Snowflake | (M) | 1.65 |
| Snowflake | (S) | 1.74 |
| Redshift | (2 x ra3.4xlarge) | 1.81 |
| Snowflake | (XS) | 1.96 |
| BigQuery |  | 3 |