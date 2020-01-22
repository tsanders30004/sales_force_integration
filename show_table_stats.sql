USE sales_force;

      SELECT 'account' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.account
UNION SELECT 'asset' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.asset
UNION SELECT 'bank_account__c' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.bank_account__c
UNION SELECT 'chain__c' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.chain__c
UNION SELECT 'identification_number__c' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.identification_number__c
UNION SELECT 'recordtype' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.recordtype
UNION SELECT 'sales_contract__c' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.sales_contract__c
UNION SELECT 'user' AS table_name, min(mysql_import_timestamp), max(mysql_import_timestamp), count(*) FROM sales_force.USER
;

