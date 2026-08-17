TECHNICAL REQUIREMENTS
1. The system shall be developed using POSTGRESQL as the database management system.
2. the system shall support ML algorithms for data analysis and prediction.
3. The system shall be designed to handle large volumes of data efficiently.
4. The system shall be designed as a datawarehouse to support data integration and analysis from multiple sources.
5. The system shall be designed as a datawarehouse with dimensions and facts to support efficient querying and analysis.

FUNCTIONAL REQUIREMENTS
1. The system shall have a Projects dimension to store information about different projects.
2. The system shall have a WorkBreakdownStructure dimension to store information about different phase and tasks within projects.
3. The system shall have a Time dimension to store information about different time periods (e.g., days, weeks, months).
4. The system shall have a Resources dimension to store information about different resources (e.g., personnel, equipment).
5. The system shall have a Customers dimension to store information about different customers or clients.
6. The system shall have a Suppliers dimension to store information about different suppliers or vendors.
7. The system shall have a Products dimension to store information about different products or deliverables.
8. The system shall have a Facts table to store Planned data as quantitative measures related to projects, work breakdown structure, time, resources, customers, suppliers and products.
9. The system shall have a Facts table to store Actual data as quantitative measures related to projects, work breakdown structure, time, resources, customers, suppliers and products.
10. The system shall have a Facts table to store Committed data as quantitative measures related to projects, work breakdown structure, time, resources, customers, suppliers and products.
