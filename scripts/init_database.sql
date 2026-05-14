/*====================================================================================================================
  Project      : Olist Data Warehouse
  Author       : Tharuka Harshajith - Data Engineer
  Description  : 
        This script initializes the Olist Data Warehouse environment by:
        1. Creating the OlistDWH database
        2. Switching context to the new database
        3. Creating schema layers based on the Medallion Architecture

        Schema Layers:
        -----------------------------------------------------------------------------------------
        bronze  -> Raw data ingestion layer
                   Stores source data with minimal or no transformation.

        silver  -> Cleansed and transformed layer
                   Handles data quality checks, standardization, and business transformations.

        gold    -> Business-ready analytical layer
                   Contains aggregated and optimized tables/views for reporting and analytics.

  Notes:
        - Script is idempotent where possible
        - Uses batch separators (GO) for execution clarity
        - Recommended to run using SQL Server Management Studio (SSMS)

====================================================================================================================*/

-- ============================================
-- Create Database
-- ============================================

USE master;
GO

IF DB_ID('OlistDWH') IS NULL
BEGIN
    CREATE DATABASE OlistDWH;
    PRINT 'Database [OlistDWH] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [OlistDWH] already exists.';
END
GO


-- ============================================
-- Switch to Olist Data Warehouse Database
-- ============================================

USE OlistDWH;
GO


-- ============================================
-- Create Bronze Schema
-- Raw Layer - Stores source extracted data
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'bronze'
)
BEGIN
    EXEC ('CREATE SCHEMA bronze');
    PRINT 'Schema [bronze] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [bronze] already exists.';
END
GO


-- ============================================
-- Create Silver Schema
-- Cleansed & transformed data layer
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC ('CREATE SCHEMA silver');
    PRINT 'Schema [silver] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [silver] already exists.';
END
GO


-- ============================================
-- Create Gold Schema
-- Business-ready analytical layer
-- ============================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC ('CREATE SCHEMA gold');
    PRINT 'Schema [gold] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [gold] already exists.';
END
GO


-- ============================================
-- Validation Check
-- ============================================

SELECT 
    schema_id,
    name AS schema_name
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold')
ORDER BY name;
GO