import http from "k6/http";
import { sleep } from 'k6';

import queriesFirebolt from '../../../poc-root/poc-customer-<>/FIREBOLT_FILES/SELECT/tuned/k6/queries.js';
import queriesSnowflake from '../../benchmarks/FireScale_k6/queries_snowflake.js';
import queriesRedshift from '../../benchmarks/FireScale_k6/queries_redshift.js';

const config = JSON.parse(open("../../config/k6config.json"));
const vendor = config.vendor;

let queries;

if (vendor === 'firebolt') {
  queries = queriesFirebolt;
} else if (vendor === 'snowflake') {
  queries = queriesSnowflake;
} else if (vendor === 'redshift') {
  queries = queriesRedshift;
} else {
  throw new Error(`Unsupported VENDOR: ${vendor}`);
}

// k6 Options
export const options = {
  vus: config.VUs ?? 10,  // Get VUs from config, default to 10 virtual users (parallel streams)
  duration: config.duration
};


const queryTypes = Object.keys(queries);  // ["query 1", "query 2", ..., "query N"]
const numQueryTypes = queryTypes.length;  // Number of query types

const API_URL = "http://localhost:3000/execute";  // Node.js API URL
const HEALTH_URL = 'http://localhost:3000/health';

export default function () {
  // k6's built-in: __VU is the VU number (1-based)
  // So each VU will be "1", "2", "3", etc.
  const vuID = __VU;
  const iter = __ITER;

  // 1) fixed mapping each round:
  // const queryIndex = vuID - 1;

  // 2) rotating mapping each round (recommended):
  const queryIndex = (vuID - 1 + iter) % numQueryTypes;

  const queryKey = queryTypes[queryIndex];
  const queryList = queries[queryKey];

  if (!Array.isArray(queryList) || queryList.length === 0) return;

  for (const queryText of queryList) {
    // Include vuID in the request payload
    const payload = JSON.stringify({
      vuID,
      query: queryText,
    });

    // Make the request
    const params = { headers: { "Content-Type": "application/json" } };
    const res = http.post(API_URL, payload, params);

    if (res.status !== 200) {
      console.error(`🚨 Query failed (VU ${vuID}): ${res.body}`);
    }
  }
}


export function setup() {
  // We’ll wait up to maxWaitSec seconds, checking /health every intervalSec seconds
  const maxWaitSec = 300;
  const intervalSec = 10;
  const startTime = Date.now();

  while ((Date.now() - startTime) / 1000 < maxWaitSec) {
    const res = http.get(HEALTH_URL, {
      tags: { name: "healthCheck" },
    });
    if (res && res.status === 200) {
      console.log('Server responded to health check. Proceeding.');
      return;
    }
    console.log('Health check failed; waiting...');
    sleep(intervalSec);
  }

  throw new Error(`Server not ready after ${maxWaitSec} seconds`);
}