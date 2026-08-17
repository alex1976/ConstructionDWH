# Construction DWH - Excel to Warehouse Process

This repository contains SQL scripts for the Construction Data Warehouse and a Python ETL flow to load **Planned**, **Committed**, and **Actual** data from Excel files.

## What is in this project

- SQL schemas:
  - `construction_dwh.sql`
  - `construction_dwh_v2.sql`
- Excel template generator:
  - `create_excel_templates.py`
- Excel-to-DWH loader:
  - `load_excel_to_dwh.py`
- Python dependencies:
  - `requirements.txt`

## End-to-end process

### 1) Create the Data Warehouse schema

Run one of the SQL scripts in your database environment (recommended schema: `dwh`).

> Note: the Python loader expects dimension/fact tables under the `dwh` schema and supports the Kimball naming (`DimDate`, `DimWBS`, `ProjectBK`, etc.).

### 2) Install Python dependencies

```powershell
pip install -r requirements.txt
```

### 3) Generate Excel templates

```powershell
python create_excel_templates.py
```

This creates:

- `Planned.xlsx`
- `Committed.xlsx`
- `Actual.xlsx`

### 4) Fill the Excel files

Each Excel file must keep these columns:

`ProjectBK, WBSBK, DateKey, ResourceBK, CustomerBK, SupplierBK, ProductBK, DocumentNumber, DocumentLineNumber, Quantity, Hours, Cost, Revenue, SourceSystem`

The first row is a sample row you can overwrite.

### 5) Configure database connection

Set an ODBC connection string in an environment variable:

```powershell
$env:DWH_CONN_STR = "Driver={ODBC Driver 17 for SQL Server};Server=localhost;Database=ConstructionDWH;Trusted_Connection=yes;"
```

Or pass `--connection-string` directly when running the loader.

### 6) Validate with dry run (recommended)

```powershell
python load_excel_to_dwh.py --excel-dir . --schema dwh --dry-run
```

This checks files and key resolution without inserting rows.

### 7) Load data into fact tables

```powershell
python load_excel_to_dwh.py --excel-dir . --schema dwh
```

Target facts:

- `dwh.FactPlanned`
- `dwh.FactCommitted`
- `dwh.FactActual`

## How key resolution works

For each row, the loader resolves surrogate keys from business keys:

- `ProjectBK -> DimProject.ProjectBK`
- `WBSBK -> DimWBS.WBSBK`
- `ResourceBK -> DimResource.ResourceBK`
- `CustomerBK -> DimCustomer.CustomerBK`
- `SupplierBK -> DimSupplier.SupplierBK`
- `ProductBK -> DimProduct.ProductBK`
- `DateKey -> DimDate.DateKey`

If a lookup does not match, the loader uses `-1` (unknown member).

## Notes

- Ensure unknown members (`-1`) exist in dimensions (already included in `construction_dwh_kimball_v2.sql`).
- If `DimAudit`/`AuditKey` are present, the loader writes audit status automatically.
- You can change the schema with `--schema`.
