from pathlib import Path

from openpyxl import Workbook


HEADERS = [
    "ProjectBK",
    "WBSBK",
    "DateKey",
    "ResourceBK",
    "CustomerBK",
    "SupplierBK",
    "ProductBK",
    "DocumentNumber",
    "DocumentLineNumber",
    "Quantity",
    "Hours",
    "Cost",
    "Revenue",
    "SourceSystem",
]


SAMPLE_ROWS = {
    "Planned": ["PRJ-001", "WBS-001", 20260115, "RES-001", "CUS-001", "SUP-001", "PROD-001", "PLAN-1001", 1, 100.0, 40.0, 12000.0, 15000.0, "ExcelTemplate"],
    "Committed": ["PRJ-001", "WBS-001", 20260115, "RES-001", "CUS-001", "SUP-001", "PROD-001", "COM-1001", 1, 100.0, 35.0, 11000.0, 14000.0, "ExcelTemplate"],
    "Actual": ["PRJ-001", "WBS-001", 20260115, "RES-001", "CUS-001", "SUP-001", "PROD-001", "ACT-1001", 1, 95.0, 38.5, 11800.0, 14800.0, "ExcelTemplate"],
}


def create_template(output_dir: Path, name: str) -> None:
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = name
    sheet.append(HEADERS)
    sheet.append(SAMPLE_ROWS[name])
    output_path = output_dir / f"{name}.xlsx"
    workbook.save(output_path)


def main() -> None:
    output_dir = Path(__file__).resolve().parent
    for file_name in ("Planned", "Committed", "Actual"):
        create_template(output_dir, file_name)
    print("Created: Planned.xlsx, Committed.xlsx, Actual.xlsx")


if __name__ == "__main__":
    main()
