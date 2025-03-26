const express = require("express");
const dotenv = require("dotenv");
const fs = require("fs");
const path = require("path");

dotenv.config({ path: "../../config/credentials/k6config.env" });

function parseArgs(argv) {
  const argsMap = {};
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg.startsWith("--")) {
      const key = arg.slice(2);
      let value = true;
      if (i + 1 < argv.length && !argv[i + 1].startsWith("--")) {
        value = argv[i + 1];
        i++;
      }
      argsMap[key] = value;
    }
  }
  return argsMap;
}

const argMap = parseArgs(process.argv.slice(2));
const credsFile = argMap.creds || "../../config/credentials/credentials.json";
const configPath = path.isAbsolute(credsFile)
  ? credsFile
  : path.resolve(process.cwd(), credsFile);  
let fileConfig = {};
try {
  if (fs.existsSync(configPath)) {
    const rawJson = fs.readFileSync(configPath, "utf-8");
    fileConfig = JSON.parse(rawJson);
  }
} catch (err) {
  console.warn("Could not read or parse credentials file:", err);
}


const fileFirebolt = fileConfig.firebolt || {};
const fileFireboltAuth = fileFirebolt.auth || {};
const FIREBOLT_ENGINE        = fileFirebolt.engine_name || process.env.FIREBOLT_ENGINE;
const FIREBOLT_DB            = fileFirebolt.database    || process.env.FIREBOLT_DB;
const FIREBOLT_ACCOUNT       = fileFirebolt.account_name || process.env.FIREBOLT_ACCOUNT;
const FIREBOLT_CLIENT_ID     = fileFireboltAuth.id      || process.env.FIREBOLT_CLIENT_ID;
const FIREBOLT_CLIENT_SECRET = fileFireboltAuth.secret  || process.env.FIREBOLT_CLIENT_SECRET;

const fileSnowflake = fileConfig.snowflake || {};
const SNOWFLAKE_ACCOUNT      = fileSnowflake.account    || process.env.SNOWFLAKE_ACCOUNT;
const SNOWFLAKE_USERNAME     = fileSnowflake.user       || process.env.SNOWFLAKE_USERNAME;
const SNOWFLAKE_KEY_PATH     = fileSnowflake.keyPath    || process.env.SNOWFLAKE_KEY_PATH;
const SNOWFLAKE_PASSPHRASE   = fileSnowflake.passphrase || process.env.SNOWFLAKE_PASSPHRASE;
const SNOWFLAKE_WAREHOUSE    = fileSnowflake.warehouse  || process.env.SNOWFLAKE_WAREHOUSE;
const SNOWFLAKE_DATABASE     = fileSnowflake.database   || process.env.SNOWFLAKE_DATABASE;
const SNOWFLAKE_SCHEMA       = fileSnowflake.schema     || process.env.SNOWFLAKE_SCHEMA;

const fileRedshift = fileConfig.redshift || {};
const REDSHIFT_HOST          = fileRedshift.host        || process.env.REDSHIFT_HOST;
const REDSHIFT_PORT          = fileRedshift.port        || process.env.REDSHIFT_PORT;
const REDSHIFT_DATABASE      = fileRedshift.database    || process.env.REDSHIFT_DATABASE;
const REDSHIFT_USER          = fileRedshift.user        || process.env.REDSHIFT_USER;
const REDSHIFT_PASSWORD      = fileRedshift.password    || process.env.REDSHIFT_PASSWORD;
const REDSHIFT_SSL           = fileRedshift.ssl         || process.env.REDSHIFT_SSL;


const { Firebolt } = require("firebolt-sdk");
const snowflake = require("snowflake-sdk");
const { Client: RedshiftClient } = require("pg");

const app = express();
app.use(express.json());

/*
 * Change this value so that CONNECTIONS_PER_SERVER * numCPUs
 * (in connections-cluster.js) is >= the total number of VUs
 * you intend on using
 */
const CONNECTIONS_PER_SERVER = process.env.CONNECTIONS_PER_SERVER || 10;
const VENDOR = process.env.VENDOR || "firebolt";

if (VENDOR === "snowflake") {
  snowflake.configure({
    logLevel: "ERROR",
    logFilePath: "/dev/null",
    additionalLogToConsole: true
  });
}



// Map for storing connections by VU ID
// Key: vuID (string or number)
// Value: a database connection instance
const connections = new Map();


async function getFireboltConnection(vuID) {
  if (!connections.has(vuID)) {
    const firebolt = Firebolt();
    const conn = await firebolt.connect({
      auth: {
        client_id: FIREBOLT_CLIENT_ID,
        client_secret: FIREBOLT_CLIENT_SECRET,
      },
      engineName: FIREBOLT_ENGINE,
      account: FIREBOLT_ACCOUNT,
      database: FIREBOLT_DB
    });
    connections.set(vuID, conn);
    await connections.get(vuID).execute("SET enable_result_cache=false")
  }
  return connections.get(vuID);
}

function connectSnowflakeAsync(conn) {
  return new Promise((resolve, reject) => {
    conn.connect((err, connResult) => {
      if (err) {
        return reject(err);
      }
      resolve(connResult);
    });
  });
}

async function getSnowflakeConnection(vuID, privateKey) {
  if (!connections.has(vuID)) {
    const conn = snowflake.createConnection({
      account: SNOWFLAKE_ACCOUNT,
      authenticator: "SNOWFLAKE_JWT",
      username: SNOWFLAKE_USERNAME,
      privateKeyPath: SNOWFLAKE_KEY_PATH,
      privateKeyPass: SNOWFLAKE_PASSPHRASE,
      warehouse: SNOWFLAKE_WAREHOUSE,
      database: SNOWFLAKE_DATABASE,
      schema: SNOWFLAKE_SCHEMA,
      logLevel: 'ERROR'
    });
    await connectSnowflakeAsync(conn);
    connections.set(vuID, conn);
    await new Promise((resolve, reject) => {
      connections.get(vuID).execute({
        sqlText: "ALTER SESSION SET USE_CACHED_RESULT = FALSE;",
        complete: (err, stmt, data) => {
          if (err) {
            return reject(err);
          }
          resolve(data);
        }
      });
    });
  }
  return connections.get(vuID);
}

async function getRedshiftConnection(vuID) {
  if (!connections.has(vuID)) {
    // Build options for node-postgres
    const clientConfig = {
      host: REDSHIFT_HOST,
      port: parseInt(REDSHIFT_PORT, 10) || 5439,
      database: REDSHIFT_DATABASE,
      user: REDSHIFT_USER,
      password: REDSHIFT_PASSWORD,
    };
    // If SSL is desired
    if (REDSHIFT_SSL === "true") {
      clientConfig.ssl = {
        rejectUnauthorized: false
      };
    }

    const client = new RedshiftClient(clientConfig);
    await client.connect();
    connections.set(vuID, client);
    await connections.get(vuID).query("SET enable_result_cache_for_session TO off;");
  }
  return connections.get(vuID);
}

// POST /execute endpoint
app.post("/execute", async (req, res) => {
  try {
    const { query, vuID } = req.body;
    if (!query || !vuID) {
      return res
        .status(400)
        .json({ error: "Both 'query' and 'vuID' fields are required" });
    }

    if (VENDOR === "firebolt") {
      const conn = connections.get((vuID % CONNECTIONS_PER_SERVER) + 1);
      const statement = await conn.execute(query);
      const { data } = await statement.fetchResult();
    } else if (VENDOR === "snowflake") {
      const conn = connections.get((vuID % CONNECTIONS_PER_SERVER) + 1);
      await new Promise((resolve, reject) => {
        conn.execute({
          sqlText: query,
          complete: (err, stmt, rows) => {
            if (err) {
              return reject(err);
            }
            resolve(rows);
          }
        });
      });
    } else if (VENDOR === "redshift") {
      const conn = connections.get((vuID % CONNECTIONS_PER_SERVER) + 1);
      const result = await conn.query(query);
    } else {
      return res.status(400).json({ error: `Unknown VENDOR: ${VENDOR}` });
    }

    res.json({ success: true });
  } catch (error) {
    console.error("Query execution error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/health', (req, res) => {
  res.send('OK');
});

// Start the server
(async function startServer() {
  try {
    const totalVUs = parseInt(CONNECTIONS_PER_SERVER, 10) || 1;

    // Pre-init connections
    console.log(`Pre-initializing ${VENDOR} connections for ${totalVUs} VUs...`);
    const query_42 = "SELECT 42";
    if (VENDOR === "firebolt") {
      await getFireboltConnection(-1);
      const statement = await connections.get(-1).execute(query_42);
      const { data } = await statement.fetchResult();
      for (let i = 1; i <= totalVUs; i++) {
        await getFireboltConnection(i);
      }
    } else if (VENDOR === "snowflake") {
      await getSnowflakeConnection(-1);
      await new Promise((resolve, reject) => {
        connections.get(-1).execute({
          sqlText: query_42,
          complete: (err, stmt, data) => {
            if (err) {
              return reject(err);
            }
            resolve(data);
          }
        });
      });
      for (let i = 1; i <= totalVUs; i++) {
        await getSnowflakeConnection(i);
      }
    } else if (VENDOR === "redshift") {
      await getRedshiftConnection(-1);
      const result = await connections.get(-1).query(query_42);
      for (let i = 1; i <= totalVUs; i++) {
        await getRedshiftConnection(i);
      }
    } else {
      console.error("No recognized VENDOR, skipping pre-init connections.");
      process.exit(1);
    }

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT}`);
      console.log(`VENDOR=${VENDOR}, VUS=${totalVUs}`);
    });
  } catch (err) {
    console.error("Failed to initialize connections:", err);
    process.exit(1);
  }
})();
