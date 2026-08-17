/*
  ConstructionDWH - T-SQL Star Schema
  Based on requirements.md

  Notes:
  - This script targets Microsoft SQL Server (T-SQL).
  - It creates a data warehouse schema with required dimensions and fact tables:
    Planned, Actual, Committed.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dwh')
    EXEC ('CREATE SCHEMA dwh AUTHORIZATION dbo;');

/* =========================
    CLEANUP FOR RE-RUNS
    ========================= */

IF OBJECT_ID('dwh.FactCommitted', 'U') IS NOT NULL DROP TABLE dwh.FactCommitted;
IF OBJECT_ID('dwh.FactActual', 'U') IS NOT NULL DROP TABLE dwh.FactActual;
IF OBJECT_ID('dwh.FactPlanned', 'U') IS NOT NULL DROP TABLE dwh.FactPlanned;

/* =========================
   DIMENSIONS
   ========================= */

IF OBJECT_ID('dwh.DimProject', 'U') IS NOT NULL DROP TABLE dwh.DimProject;
CREATE TABLE dwh.DimProject (
    ProjectKey           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectCode          NVARCHAR(50) NOT NULL,
    ProjectName          NVARCHAR(255) NOT NULL,
    ProjectType          NVARCHAR(100) NULL,
    ProjectStatus        NVARCHAR(50) NULL,
    StartDate            DATE NULL,
    EndDate              DATE NULL,
    BudgetAmount         DECIMAL(18,2) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_DimProject_IsActive DEFAULT (1),
    CreatedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_DimProject_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt            DATETIME2(0) NULL,
    CONSTRAINT UQ_DimProject_ProjectCode UNIQUE (ProjectCode)
);

IF OBJECT_ID('dwh.DimWorkBreakdownStructure', 'U') IS NOT NULL DROP TABLE dwh.DimWorkBreakdownStructure;
CREATE TABLE dwh.DimWorkBreakdownStructure (
    WBSKey               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectKey           INT NOT NULL,
    WBSCode              NVARCHAR(50) NOT NULL,
    WBSName              NVARCHAR(255) NOT NULL,
    WBSType              NVARCHAR(50) NULL,
    ParentWBSKey         INT NULL,
    WBSLevel             INT NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_DimWBS_IsActive DEFAULT (1),
    CreatedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_DimWBS_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt            DATETIME2(0) NULL,
    CONSTRAINT UQ_DimWBS_Project_WBSCode UNIQUE (ProjectKey, WBSCode),
    CONSTRAINT FK_DimWBS_Project FOREIGN KEY (ProjectKey) REFERENCES dwh.DimProject(ProjectKey),
    CONSTRAINT FK_DimWBS_Parent FOREIGN KEY (ParentWBSKey) REFERENCES dwh.DimWorkBreakdownStructure(WBSKey)
);

IF OBJECT_ID('dwh.DimTime', 'U') IS NOT NULL DROP TABLE dwh.DimTime;
CREATE TABLE dwh.DimTime (
    DateKey              INT NOT NULL PRIMARY KEY,
    [Date]               DATE NOT NULL,
    DayNumberOfMonth     TINYINT NOT NULL,
    DayName              NVARCHAR(20) NOT NULL,
    DayOfWeekISO         TINYINT NOT NULL,
    WeekNumberISO        TINYINT NOT NULL,
    MonthNumber          TINYINT NOT NULL,
    MonthName            NVARCHAR(20) NOT NULL,
    QuarterNumber        TINYINT NOT NULL,
    [Year]               SMALLINT NOT NULL,
    YearMonth            CHAR(7) NOT NULL,
    IsWeekend            BIT NOT NULL,
    IsMonthEnd           BIT NOT NULL,
    CONSTRAINT UQ_DimTime_Date UNIQUE ([Date])
);

IF OBJECT_ID('dwh.DimResource', 'U') IS NOT NULL DROP TABLE dwh.DimResource;
CREATE TABLE dwh.DimResource (
    ResourceKey          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ResourceCode         NVARCHAR(50) NOT NULL,
    ResourceName         NVARCHAR(255) NOT NULL,
    ResourceType         NVARCHAR(50) NOT NULL,
    Department           NVARCHAR(100) NULL,
    UnitOfMeasure        NVARCHAR(30) NULL,
    HourlyRate           DECIMAL(18,2) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_DimResource_IsActive DEFAULT (1),
    CreatedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_DimResource_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt            DATETIME2(0) NULL,
    CONSTRAINT UQ_DimResource_ResourceCode UNIQUE (ResourceCode)
);

IF OBJECT_ID('dwh.DimCustomer', 'U') IS NOT NULL DROP TABLE dwh.DimCustomer;
CREATE TABLE dwh.DimCustomer (
    CustomerKey          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerCode         NVARCHAR(50) NOT NULL,
    CustomerName         NVARCHAR(255) NOT NULL,
    CustomerSegment      NVARCHAR(100) NULL,
    Country              NVARCHAR(100) NULL,
    Region               NVARCHAR(100) NULL,
    City                 NVARCHAR(100) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_DimCustomer_IsActive DEFAULT (1),
    CreatedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_DimCustomer_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt            DATETIME2(0) NULL,
    CONSTRAINT UQ_DimCustomer_CustomerCode UNIQUE (CustomerCode)
);

IF OBJECT_ID('dwh.DimSupplier', 'U') IS NOT NULL DROP TABLE dwh.DimSupplier;
CREATE TABLE dwh.DimSupplier (
    SupplierKey          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SupplierCode         NVARCHAR(50) NOT NULL,
    SupplierName         NVARCHAR(255) NOT NULL,
    SupplierCategory     NVARCHAR(100) NULL,
    Country              NVARCHAR(100) NULL,
    Region               NVARCHAR(100) NULL,
    City                 NVARCHAR(100) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_DimSupplier_IsActive DEFAULT (1),
    CreatedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_DimSupplier_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt            DATETIME2(0) NULL,
    CONSTRAINT UQ_DimSupplier_SupplierCode UNIQUE (SupplierCode)
);

IF OBJECT_ID('dwh.DimProduct', 'U') IS NOT NULL DROP TABLE dwh.DimProduct;
CREATE TABLE dwh.DimProduct (
    ProductKey           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductCode          NVARCHAR(50) NOT NULL,
    ProductName          NVARCHAR(255) NOT NULL,
    ProductCategory      NVARCHAR(100) NULL,
    UnitOfMeasure        NVARCHAR(30) NULL,
    StandardCost         DECIMAL(18,2) NULL,
    IsActive             BIT NOT NULL CONSTRAINT DF_DimProduct_IsActive DEFAULT (1),
    CreatedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_DimProduct_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt            DATETIME2(0) NULL,
    CONSTRAINT UQ_DimProduct_ProductCode UNIQUE (ProductCode)
);

/* =========================
   FACT TABLE TEMPLATE FIELDS
   ========================= */

IF OBJECT_ID('dwh.FactPlanned', 'U') IS NOT NULL DROP TABLE dwh.FactPlanned;
CREATE TABLE dwh.FactPlanned (
    FactPlannedKey       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectKey           INT NOT NULL,
    WBSKey               INT NOT NULL,
    DateKey              INT NOT NULL,
    ResourceKey          INT NOT NULL,
    CustomerKey          INT NOT NULL,
    SupplierKey          INT NOT NULL,
    ProductKey           INT NOT NULL,
    Quantity             DECIMAL(18,4) NOT NULL CONSTRAINT DF_FactPlanned_Quantity DEFAULT (0),
    PlannedHours         DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactPlanned_Hours DEFAULT (0),
    PlannedCost          DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactPlanned_Cost DEFAULT (0),
    PlannedRevenue       DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactPlanned_Revenue DEFAULT (0),
    LoadDtm              DATETIME2(0) NOT NULL CONSTRAINT DF_FactPlanned_LoadDtm DEFAULT (SYSUTCDATETIME()),
    SourceSystem         NVARCHAR(100) NULL,
    CONSTRAINT FK_FactPlanned_Project  FOREIGN KEY (ProjectKey) REFERENCES dwh.DimProject(ProjectKey),
    CONSTRAINT FK_FactPlanned_WBS      FOREIGN KEY (WBSKey) REFERENCES dwh.DimWorkBreakdownStructure(WBSKey),
    CONSTRAINT FK_FactPlanned_Date     FOREIGN KEY (DateKey) REFERENCES dwh.DimTime(DateKey),
    CONSTRAINT FK_FactPlanned_Resource FOREIGN KEY (ResourceKey) REFERENCES dwh.DimResource(ResourceKey),
    CONSTRAINT FK_FactPlanned_Customer FOREIGN KEY (CustomerKey) REFERENCES dwh.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactPlanned_Supplier FOREIGN KEY (SupplierKey) REFERENCES dwh.DimSupplier(SupplierKey),
    CONSTRAINT FK_FactPlanned_Product  FOREIGN KEY (ProductKey) REFERENCES dwh.DimProduct(ProductKey)
);

IF OBJECT_ID('dwh.FactActual', 'U') IS NOT NULL DROP TABLE dwh.FactActual;
CREATE TABLE dwh.FactActual (
    FactActualKey        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectKey           INT NOT NULL,
    WBSKey               INT NOT NULL,
    DateKey              INT NOT NULL,
    ResourceKey          INT NOT NULL,
    CustomerKey          INT NOT NULL,
    SupplierKey          INT NOT NULL,
    ProductKey           INT NOT NULL,
    Quantity             DECIMAL(18,4) NOT NULL CONSTRAINT DF_FactActual_Quantity DEFAULT (0),
    ActualHours          DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactActual_Hours DEFAULT (0),
    ActualCost           DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactActual_Cost DEFAULT (0),
    ActualRevenue        DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactActual_Revenue DEFAULT (0),
    LoadDtm              DATETIME2(0) NOT NULL CONSTRAINT DF_FactActual_LoadDtm DEFAULT (SYSUTCDATETIME()),
    SourceSystem         NVARCHAR(100) NULL,
    CONSTRAINT FK_FactActual_Project   FOREIGN KEY (ProjectKey) REFERENCES dwh.DimProject(ProjectKey),
    CONSTRAINT FK_FactActual_WBS       FOREIGN KEY (WBSKey) REFERENCES dwh.DimWorkBreakdownStructure(WBSKey),
    CONSTRAINT FK_FactActual_Date      FOREIGN KEY (DateKey) REFERENCES dwh.DimTime(DateKey),
    CONSTRAINT FK_FactActual_Resource  FOREIGN KEY (ResourceKey) REFERENCES dwh.DimResource(ResourceKey),
    CONSTRAINT FK_FactActual_Customer  FOREIGN KEY (CustomerKey) REFERENCES dwh.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactActual_Supplier  FOREIGN KEY (SupplierKey) REFERENCES dwh.DimSupplier(SupplierKey),
    CONSTRAINT FK_FactActual_Product   FOREIGN KEY (ProductKey) REFERENCES dwh.DimProduct(ProductKey)
);

IF OBJECT_ID('dwh.FactCommitted', 'U') IS NOT NULL DROP TABLE dwh.FactCommitted;
CREATE TABLE dwh.FactCommitted (
    FactCommittedKey     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProjectKey           INT NOT NULL,
    WBSKey               INT NOT NULL,
    DateKey              INT NOT NULL,
    ResourceKey          INT NOT NULL,
    CustomerKey          INT NOT NULL,
    SupplierKey          INT NOT NULL,
    ProductKey           INT NOT NULL,
    Quantity             DECIMAL(18,4) NOT NULL CONSTRAINT DF_FactCommitted_Quantity DEFAULT (0),
    CommittedHours       DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactCommitted_Hours DEFAULT (0),
    CommittedCost        DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactCommitted_Cost DEFAULT (0),
    CommittedRevenue     DECIMAL(18,2) NOT NULL CONSTRAINT DF_FactCommitted_Revenue DEFAULT (0),
    LoadDtm              DATETIME2(0) NOT NULL CONSTRAINT DF_FactCommitted_LoadDtm DEFAULT (SYSUTCDATETIME()),
    SourceSystem         NVARCHAR(100) NULL,
    CONSTRAINT FK_FactCommitted_Project  FOREIGN KEY (ProjectKey) REFERENCES dwh.DimProject(ProjectKey),
    CONSTRAINT FK_FactCommitted_WBS      FOREIGN KEY (WBSKey) REFERENCES dwh.DimWorkBreakdownStructure(WBSKey),
    CONSTRAINT FK_FactCommitted_Date     FOREIGN KEY (DateKey) REFERENCES dwh.DimTime(DateKey),
    CONSTRAINT FK_FactCommitted_Resource FOREIGN KEY (ResourceKey) REFERENCES dwh.DimResource(ResourceKey),
    CONSTRAINT FK_FactCommitted_Customer FOREIGN KEY (CustomerKey) REFERENCES dwh.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactCommitted_Supplier FOREIGN KEY (SupplierKey) REFERENCES dwh.DimSupplier(SupplierKey),
    CONSTRAINT FK_FactCommitted_Product  FOREIGN KEY (ProductKey) REFERENCES dwh.DimProduct(ProductKey)
);

/* =========================
   INDEXES FOR STAR-JOIN PERFORMANCE
   ========================= */

CREATE INDEX IX_DimWBS_ProjectKey ON dwh.DimWorkBreakdownStructure(ProjectKey);
CREATE INDEX IX_DimWBS_ParentWBSKey ON dwh.DimWorkBreakdownStructure(ParentWBSKey);

CREATE INDEX IX_FactPlanned_Grain
ON dwh.FactPlanned(ProjectKey, WBSKey, DateKey, ResourceKey, CustomerKey, SupplierKey, ProductKey);

CREATE INDEX IX_FactActual_Grain
ON dwh.FactActual(ProjectKey, WBSKey, DateKey, ResourceKey, CustomerKey, SupplierKey, ProductKey);

CREATE INDEX IX_FactCommitted_Grain
ON dwh.FactCommitted(ProjectKey, WBSKey, DateKey, ResourceKey, CustomerKey, SupplierKey, ProductKey);

/* =========================
   TIME DIMENSION POPULATION
   ========================= */

IF OBJECT_ID('dwh.usp_PopulateDimTime', 'P') IS NOT NULL
    DROP PROCEDURE dwh.usp_PopulateDimTime;
GO

CREATE PROCEDURE dwh.usp_PopulateDimTime
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET DATEFIRST 1;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @EndDate < @StartDate
    BEGIN
        THROW 50001, 'Invalid date range for DimTime population.', 1;
    END;

    ;WITH d AS (
        SELECT @StartDate AS [Date]
        UNION ALL
        SELECT DATEADD(DAY, 1, [Date])
        FROM d
        WHERE [Date] < @EndDate
    )
    INSERT INTO dwh.DimTime (
        DateKey,
        [Date],
        DayNumberOfMonth,
        DayName,
        DayOfWeekISO,
        WeekNumberISO,
        MonthNumber,
        MonthName,
        QuarterNumber,
        [Year],
        YearMonth,
        IsWeekend,
        IsMonthEnd
    )
    SELECT
        CONVERT(INT, FORMAT(d.[Date], 'yyyyMMdd')) AS DateKey,
        d.[Date],
        DATEPART(DAY, d.[Date]) AS DayNumberOfMonth,
        DATENAME(WEEKDAY, d.[Date]) AS DayName,
        DATEPART(WEEKDAY, d.[Date]) AS DayOfWeekISO,
        DATEPART(ISOWK, d.[Date]) AS WeekNumberISO,
        DATEPART(MONTH, d.[Date]) AS MonthNumber,
        DATENAME(MONTH, d.[Date]) AS MonthName,
        DATEPART(QUARTER, d.[Date]) AS QuarterNumber,
        DATEPART(YEAR, d.[Date]) AS [Year],
        CONVERT(CHAR(7), d.[Date], 126) AS YearMonth,
        CASE WHEN DATEPART(WEEKDAY, d.[Date]) IN (6, 7) THEN 1 ELSE 0 END AS IsWeekend,
        CASE WHEN EOMONTH(d.[Date]) = d.[Date] THEN 1 ELSE 0 END AS IsMonthEnd
    FROM d
    WHERE NOT EXISTS (
        SELECT 1
        FROM dwh.DimTime t
        WHERE t.[Date] = d.[Date]
    )
    OPTION (MAXRECURSION 0);
END;
GO

/*
  Example usage:
  EXEC dwh.usp_PopulateDimTime @StartDate = '2020-01-01', @EndDate = '2030-12-31';
*/
