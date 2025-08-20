import http from "k6/http";
import { sleep } from 'k6';

import queriesFirebolt from '../../../poc-root/poc-customer-/FIREBOLT_FILES/SELECT/tuned/k6/queries.js';
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
  const iter = __ITER; // round number

  // Build one batch: 25 parallel requests (one per query)
  const batch = [];
  for (let queryIndex = 0; queryIndex < numQueryTypes; queryIndex++) {
    const queryKey = queryTypes[queryIndex];
    const queryList = queries[queryKey];

    // If your API accepts multi-statement SQL, keep it as-is; else pick the first statement.
    const queryText = Array.isArray(queryList) ? queryList.join("\n") : String(queryList);

    // Synthetic vuID to preserve your payload schema (1..25)
    const vuID = queryIndex + 1;

    const payload = JSON.stringify({ vuID, name: queryKey, query: queryText });
    const params = { headers: { "Content-Type": "application/json" }, tags: { queryKey } };
    batch.push(["POST", API_URL, payload, params]);
  }

  const responses = http.batch(batch);

  // Handle errors
  for (let i = 0; i < responses.length; i++) {
    if (responses[i].status !== 200) {
      const queryKey = queryTypes[i];
      console.error(`🚨 Query failed (round ${iter}, ${queryKey}): ${responses[i].status} ${responses[i].body}`);
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