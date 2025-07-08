from .bigquery import BigQueryConnector
from .firebolt import FireboltConnector
from .redshift import RedshiftConnector
from .snowflake import SnowflakeConnector
from .databricks import DatabricksConnector

__all__ = [
    "FireboltConnector",
    "SnowflakeConnector",
    "BigQueryConnector",
    "RedshiftConnector",
    "DatabricksConnector"
]


def get_connector_class(vendor: str):
    """Get the appropriate connector class for a vendor."""
    connector_map = {
        "snowflake": SnowflakeConnector,
        "firebolt": FireboltConnector,
        "bigquery": BigQueryConnector,
        "redshift": RedshiftConnector,
        "databricks": DatabricksConnector
    }
    if vendor not in connector_map:
        raise ValueError(f"Unsupported vendor: {vendor}")
    return connector_map[vendor]
