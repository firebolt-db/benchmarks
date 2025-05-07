import snowflake.connector
from typing import Optional, Dict, List, Any
from contextlib import contextmanager

class SnowflakeConnector:
    def __init__(self, config: Dict[str, str]):
        """
        Initialize Snowflake connector with configuration parameters.
        
        Args:
            config (Dict[str, str]): Configuration dictionary containing:
                - account: Snowflake account identifier
                - user: Snowflake username
                - password: Snowflake password
                - warehouse: (Optional) Default warehouse
                - database: (Optional) Default database
                - schema: (Optional) Default schema
        """
        self.config = config
        self._validate_config()
        self._conn = None
        self._cursor = None

    def _validate_config(self) -> None:
        """Validate that required configuration parameters are present."""
        required_params = ['account', 'user', 'password']
        missing_params = [param for param in required_params if param not in self.config]
        if missing_params:
            raise ValueError(f"Missing required configuration parameters: {missing_params}")

    @contextmanager
    def connect(self):
        """Context manager for database connections."""
        if not self._conn:
            connect_args = {
                "account": self.config["account"],
                "user": self.config["user"],
                "warehouse": self.config.get("warehouse"),
                "database": self.config.get("database"),
                "schema": self.config.get("schema"),
                "telemetry": False,
            }
            if "privateKeyPath" in self.config:
                connect_args.update({
                    "authenticator": "SNOWFLAKE_JWT",
                    "private_key_file": self.config["privateKeyPath"],
                    "private_key_file_pwd": self.config.get("privateKeyPass"),
                })
            else:
                connect_args["password"] = self.config["password"]
            self._conn = snowflake.connector.connect(**connect_args)
            self._cursor = self._conn.cursor(snowflake.connector.DictCursor)
            self._cursor.execute("ALTER SESSION SET USE_CACHED_RESULT = FALSE;")

    def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None) -> List[Dict]:
        """
        Execute a SQL query and return results as a list of dictionaries.
        
        Args:
            query (str): SQL query to execute
            params (Optional[Dict[str, Any]]): Query parameters for parameterized queries
            
        Returns:
            List[Dict]: Query results as a list of dictionaries
        """
        if not self._conn or not self._cursor:
            self.connect()

        try:
            self._cursor.execute(query, params or {})
            return self._cursor.fetchall()
        except Exception as e:
            raise Exception(f"Error executing query: {str(e)}")


    def close(self) -> None:
        """Close the Snowflake connection if it exists."""
        if self._conn:
            self._conn.close()
            self._conn = None
            self._cursor = None
