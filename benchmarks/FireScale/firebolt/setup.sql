DROP AGGREGATING INDEX IF EXISTS idx_by_day;
DROP TABLE IF EXISTS uservisits;
DROP TABLE IF EXISTS rankings;
DROP TABLE IF EXISTS ipaddresses;
DROP TABLE IF EXISTS agents;
DROP TABLE IF EXISTS searchwords;   

CREATE TABLE "uservisits" ("sourceip" text NOT NULL, 
"destinationurl" text NOT NULL,
"visitdate" pgdate NOT NULL,
"adrevenue" REAL NOT NULL, 
"useragent" text NOT NULL, 
"countrycode" text NOT NULL,
"languagecode" text NOT NULL,
"searchword" text NOT NULL, 
"duration" integer NOT NULL) 
PRIMARY INDEX "visitdate", "destinationurl", "sourceip";

CREATE TABLE "ipaddresses" ("ip" text NOT NULL,
"autonomoussystem" integer NOT NULL,
"asname" text NOT NULL)
PRIMARY INDEX "ip";

CREATE TABLE "rankings" ("pageurl" text NOT NULL,
"pagerank" integer NULL,
"avgduration" integer NOT NULL) 
PRIMARY INDEX "pageurl";

CREATE TABLE "agents" ("id" integer NOT NULL,
"agentname" text NOT NULL,
"operatingsystem" text NOT NULL,
"devicearch" text NOT NULL,
"browser" text NOT NULL);

CREATE TABLE "searchwords" ("word" text NOT NULL,
"word_hash" bigint NOT NULL,
"word_id" bigint NOT NULL,
"firstseen" pgdate NOT NULL,
"is_topic" boolean NOT NULL);

COPY
INTO
	uservisits
FROM
	's3://firebolt-benchmarks-requester-pays-us-east-1/firenewt/1tb/uservisits/gz-parquet/'
WITH
	CREDENTIALS = (AWS_ROLE_ARN = 'arn:aws:iam::442042532160:role/FireboltS3DatasetsAccess')
	TYPE = parquet;

COPY
INTO
	rankings
FROM
	's3://firebolt-benchmarks-requester-pays-us-east-1/firenewt/1tb/rankings/'
WITH
	CREDENTIALS = (AWS_ROLE_ARN = 'arn:aws:iam::442042532160:role/FireboltS3DatasetsAccess')
	TYPE = parquet;

COPY
INTO
	ipaddresses
FROM
	's3://firebolt-benchmarks-requester-pays-us-east-1/firenewt/1tb/dimensions/ipaddresses/'
WITH
	CREDENTIALS = (AWS_ROLE_ARN = 'arn:aws:iam::442042532160:role/FireboltS3DatasetsAccess')
	TYPE = parquet;

COPY
INTO
	agents
FROM
	's3://firebolt-benchmarks-requester-pays-us-east-1/firenewt/1tb/dimensions/agents/'
WITH
	CREDENTIALS = (AWS_ROLE_ARN = 'arn:aws:iam::442042532160:role/FireboltS3DatasetsAccess')
	TYPE = parquet;

COPY
INTO
	searchwords
FROM
	's3://firebolt-benchmarks-requester-pays-us-east-1/firenewt/1tb/dimensions/searchwords/'
WITH
	CREDENTIALS = (AWS_ROLE_ARN = 'arn:aws:iam::442042532160:role/FireboltS3DatasetsAccess')
	TYPE = parquet;

VACUUM uservisits;

VACUUM uservisits;

VACUUM rankings;

VACUUM searchwords;

VACUUM agents;

VACUUM ipaddresses;