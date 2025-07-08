from databricks import sql
from typing import Any, Dict, Optional, List

class DatabricksConnector:
    def __init__(self, config: Dict[str, str]):
        """
        Initialize Databricks connector with configuration parameters.
        
        Args:
            config (Dict[str, str]): Configuration dictionary containing:
            "server_hostname": "your sql warehouse hostname",
            "http_path": "http path for warehouse",
            "access_token": "your databricks personal access token",
            "catalog": "Databricks warehouse name",
            "schema": "Databricks schema name"
        """
        self.config = config
        self._validate_config()
        self._conn = None
        self.cursor = None

    def _validate_config(self) -> None:
        """Validate that required configuration parameters are present."""
        required_params = ['server_hostname', 'http_path', 'access_token', 'catalog', 'schema']
        missing_params = [param for param in required_params if param not in self.config]
        if missing_params:
            raise ValueError(f"Missing required configuration parameters: {missing_params}")

    def connect(self) -> None:
        """Connect to Databricks using stored configuration."""
        if not self._conn:
            self._conn = sql.connect(
                server_hostname=self.config['server_hostname'],
                http_path=self.config['http_path'],
                access_token=self.config['access_token'],
                catalog=self.config['catalog'],
                schema=self.config['schema']
            )
            self.cursor = self._conn.cursor()
            self.cursor.execute("SET use_cached_result = false;")

    def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None) -> List[Dict]:
        """
        Execute a SQL query and return results as a list of dictionaries.
        
        Args:
            query (str): SQL query to execute
            params (Optional[Dict[str, Any]]): Query parameters for parameterized queries
            
        Returns:
            List[Dict]: Query results as a list of dictionaries
        """
        if not self._conn or not self.cursor:
            self.connect()

        try:
            self.cursor.execute(query, params or {})
            return self.cursor.fetchall()
        except Exception as e:
            raise Exception(f"Error executing query: {str(e)}")

    def close(self) -> None:
        """Close the Databricks connection if it exists."""
        if self._conn:
            self._conn.close()
            self._conn = None
            self.cursor = None