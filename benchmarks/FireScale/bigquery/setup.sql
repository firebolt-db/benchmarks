
CREATE SCHEMA IF NOT EXISTS `FIRESCALE_DS`
OPTIONS(location='us-east1');


-- Table: RANKINGS
CREATE TABLE IF NOT EXISTS FIRESCALE_DS.rankings (
  PAGEURL STRING NOT NULL,
  PAGERANK INT64,
  AVGDURATION INT64
)
PARTITION BY DATE(_PARTITIONTIME)
CLUSTER BY PAGEURL;

-- Table: USERVISITS
CREATE TABLE IF NOT EXISTS FIRESCALE_DS.uservisits (
  SOURCEIP STRING NOT NULL,
  DESTINATIONURL STRING NOT NULL,
  VISITDATE DATE NOT NULL,
  ADREVENUE FLOAT64 NOT NULL,
  USERAGENT STRING NOT NULL,
  COUNTRYCODE STRING NOT NULL,
  LANGUAGECODE STRING NOT NULL,
  SEARCHWORD STRING NOT NULL,
  DURATION INT64 NOT NULL
)
PARTITION BY DATE_TRUNC(visitdate, YEAR)
CLUSTER BY visitdate, destinationurl, sourceip;

-- Table: AGENTS
CREATE TABLE IF NOT EXISTS FIRESCALE_DS.agents (
  ID INT64 NOT NULL,
  AGENTNAME STRING,
  OPERATINGSYSTEM STRING,
  DEVICEARCH STRING,
  BROWSER STRING
);

-- Table: IPADDRESSES
CREATE TABLE IF NOT EXISTS FIRESCALE_DS.ipaddresses (
  IP STRING NOT NULL,
  AUTONOMOUSSYSTEM INT64 NOT NULL,
  ASNAME STRING
)
CLUSTER BY IP;

-- Table: SEARCHWORDS
CREATE TABLE IF NOT EXISTS FIRESCALE_DS.searchwords (
  WORD STRING NOT NULL,
  WORD_HASH INT64 NOT NULL,
  WORD_ID INT64 NOT NULL,
  FIRSTSEEN DATE NOT NULL,
  IS_TOPIC BOOL NOT NULL
);

-- External Table: RANKINGS
CREATE OR REPLACE EXTERNAL TABLE FIRESCALE_DS.ext_rankings
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://benchmark-amplab/dataapp/1tb/rankings/*']
);

-- External Table: USERVISITS
CREATE OR REPLACE EXTERNAL TABLE FIRESCALE_DS.ext_uservisits
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://benchmark-amplab/dataapp/1tb/gz-parquet/*']
);

-- External Table: AGENTS
CREATE OR REPLACE EXTERNAL TABLE FIRESCALE_DS.ext_agents
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://benchmark-amplab/dataapp/1tb/dimensions/agents/*']
);

-- External Table: IPADDRESSES
CREATE OR REPLACE EXTERNAL TABLE FIRESCALE_DS.ext_ipaddresses
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://benchmark-amplab/dataapp/1tb/dimensions/ipaddresses/*']
);

-- External Table: SEARCHWORDS
CREATE OR REPLACE EXTERNAL TABLE FIRESCALE_DS.ext_searchwords
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://benchmark-amplab/dataapp/1tb/dimensions/searchwords/*']
);

-- Load data into RANKINGS
INSERT INTO FIRESCALE_DS.rankings
SELECT * FROM FIRESCALE_DS.ext_rankings;

-- Load data into USERVISITS
INSERT INTO FIRESCALE_DS.uservisits
SELECT * FROM FIRESCALE_DS.ext_uservisits;

-- Load data into AGENTS
INSERT INTO FIRESCALE_DS.agents
SELECT * FROM FIRESCALE_DS.ext_agents;

-- Load data into IPADDRESSES
INSERT INTO FIRESCALE_DS.ipaddresses
SELECT * FROM FIRESCALE_DS.ext_ipaddresses;

-- Load data into SEARCHWORDS
INSERT INTO FIRESCALE_DS.searchwords
SELECT * FROM FIRESCALE_DS.ext_searchwords;

CREATE MATERIALIZED VIEW idx_by_day AS
SELECT
  visitdate,
  countrycode,
  languagecode,
  useragent,
  MAX(visitdate) AS max_date,
  SUM(adrevenue) AS sum_adrevenue,
  MAX(adrevenue) AS max_adrevenue,
  COUNT(*)
FROM uservisits
GROUP BY visitdate, countrycode, languagecode, useragent
ORDER BY visitdate, countrycode, languagecode, useragent;
