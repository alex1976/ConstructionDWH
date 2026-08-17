# Excel to DWH Loader

## 1) Install dependencies

```powershell
pip install -r requirements.txt
```

## 2) Create/refresh Excel templates

```powershell
python create_excel_templates.py
```

This creates:
- `Planned.xlsx`
- `Committed.xlsx`
- `Actual.xlsx`

## 3) Populate Excel rows

Keep these columns in each file:

`ProjectBK, WBSBK, DateKey, ResourceBK, CustomerBK, SupplierBK, ProductBK, DocumentNumber, DocumentLineNumber, Quantity, Hours, Cost, Revenue, SourceSystem`

## 4) Load into DWH

Set your PostgreSQL connection string in `DWH_CONN_STR` or pass it directly.

```powershell
$env:DWH_CONN_STR = "postgresql://postgres:postgres@localhost:5432/ConstructionDWH"
python load_excel_to_dwh.py --excel-dir . --schema dwh
```

Dry run validation (no insert):

```powershell
python load_excel_to_dwh.py --excel-dir . --schema dwh --dry-run
```
