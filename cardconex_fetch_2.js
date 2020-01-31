// Libraries
const alasql  = require('alasql');      // http://alasql.org/
const mysql   = require('mysql');       
const jsforce = require('jsforce');     // https://jsforce.github.io/document/#query
const config  = require('./config');
const Papa    = require('papaparse');
const fs      = require('fs');

var sfObject  = process.argv.slice(2)[0].substring(2); // sales force object name must be supplied as a command-line parameter.

// sales force
var sfConnect = new jsforce.Connection();  
var sfUserId = config.sf.user;
var sfPassword = config.sf.password;

// mysql
var mySqlConnection = mysql.createConnection({host: 'localhost', user: 'tsanders', password: 'rambuteau', database: 'sales_force'}); // mysql

var supportedTables = [
    'Account'
   ,'Asset'
   ,'Bank_Account__c'
   ,'Chain__c'
   ,'Identification_Number__c'
   ,'RecordType'
   ,'Sales_Contract__c'
   ,'User'
];

var countSalesForceRecords;
var fetchedSalesForceRecords;

var accountFields = 'AccountNumber, Site, AccountSource, Account_Status__c, Active_ACH_IDs__c, Active_Acquiring_IDs__c, Active_Encryption_IDs__c, Active_Gateway_IDs__c, Active_Services__c, Additional_Documentation_Needed__c, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode, BillingStreet, Billing_Contact_Email_Addresses__c, Business_Start_Date__c, CreatedById, CreatedDate, Customer_Number__c, DBA_Name__c, Description, Exemption_No__c, Id, Industry, IsPartner, Is_501c3__c, LastActivityDate, LastModifiedById, LastModifiedDate, Lead_Type__c, Legacy_ID__c, Legacy_Source__c, Max_Contract_End_Date__c, Months_In_Business__c, Name, NumberOfEmployees, Open_Opportunities__c, Open_Opportunity_Amount__c, OrganizationID__c, OwnerId, ParentId, Partnership_Type__c, Partner_Service_Instructions__c, Phone, PhotoUrl, RecordTypeId, Revenue_Segment__c, ShippingAddress, ShippingCity, ShippingCountry, ShippingCountryCode, ShippingGeocodeAccuracy, ShippingLatitude, ShippingLongitude, ShippingPostalCode, ShippingState, ShippingStateCode, ShippingStreet, Sic, SicDesc, Type, Unique_Count__c, Website';

var assetFields = 'AccountId, AssetLevel, ContractId__c, CreatedById, CreatedDate, Description, Fee_Amount_Text__c, Fee_Amount__c, Fee_Group__c, Fee_Name__c, Id, Identification_NumberId__c, ID_Number_Text__c, InstallDate, LastModifiedById, LastModifiedDate, Name, OwnerId, ParentId, Price, Product2Id, ProductCode, PurchaseDate, Quantity, Quote_Line_ItemId__c, Sales_ContractId__c, SerialNumber, Status, UsageEndDate';

var bankAccountFields = 'Bank_Name__c, ABA__c, AccountId__c, Account_Type__c, ACH_Debit_Account_Name__c, ACH_Descriptor__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_City__c, Bank_Contact_Name__c, Bank_Phone__c, Bank_Postal_Code__c, Bank_State__c, Bank_Street_Address__c, Business_Person_Named_on_teh_account__c, CreatedById, CreatedDate, Id, LastModifiedDate, Name';

var chainFields = 'CreatedById, CreatedDate, Id, LastModifiedById, LastModifiedDate, Legacy_ID__c, Name, OwnerId, Total_Residual_After_Payout_All_Time__c, Type_of_Chain__c';

var identificationNumberFields = 'AccountId__c, Category__c, Close_Date__c, CreatedById, CreatedDate, Id, LastModifiedById, LastModifiedDate, Name, OwnerId, RecordTypeId, Start_Date__c, Status__c, Type__c, Unique_ID__c, Warnings__c';

var recordTypeFields = 'BusinessProcessId, CreatedById, CreatedDate, Description, DeveloperName, Id, IsActive, LastModifiedById, LastModifiedDate, Name, NamespacePrefix, SobjectType';

var salesContractFields = 'AccountId__c, Additional_Documentation_Needed__c, Billing_AccountId__c, Billing_Frequency__c, Billing_Hold_Reason__c, Billing_Hold_Release_Date__c, Billing_Month__c, Billing_Preference__c, Collection_Method__c, Contract_End_Date__c, Contract_Start_Date__c, Contract_Term_months__c, CreatedById, CreatedDate, Hold_Billing__c, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, Name, OpportunityId__c, OrganizationId__c, OwnerId, PriceBookId__c, RecordTypeId, Revenue_Segment__c, Status__c';

var userFields = 'Id, Name, FirstName, LastName';
    
function getSelectStatement(sql, tableName){
    return 'SELECT '.concat(sql).concat(' FROM ').concat(tableName);
}

function getInsertStatement(sql, tableName){
    return 'INSERT INTO '.concat(tableName).concat('(').concat(sql).concat(') VALUES ?'); 
}

/* main */

    if(supportedTables.indexOf(sfObject) < 0){
        console.log('The table you specified is not supported. Currently supported tables are:\r\n ');
        for(var i=0; i<supportedTables.length; i++){
            console.log('* ' + supportedTables[i]);
        }
        process.exit();
    }
    
    console.log('Retrieving data for ' + sfObject + '...');

    if(sfObject=='Account'){
        var sqlSelect = getSelectStatement(accountFields, sfObject);
        var sqlInsert = getInsertStatement(accountFields, sfObject);  
    }else if(sfObject=='Asset'){
        var sqlSelect = getSelectStatement(assetFields, sfObject);
        var sqlInsert = getInsertStatement(assetFields, sfObject);       
    }else if(sfObject=='Bank_Account__c'){
        var sqlSelect = getSelectStatement(bankAccountFields, sfObject);
        var sqlInsert = getInsertStatement(bankAccountFields, sfObject);       
    }else if(sfObject=='Chain__c'){
        var sqlSelect = getSelectStatement(chainFields, sfObject);
        var sqlInsert = getInsertStatement(chainFields, sfObject);       
    }else if(sfObject=='Identification_Number__c'){
        var sqlSelect = getSelectStatement(identificationNumberFields, sfObject);
        var sqlInsert = getInsertStatement(identificationNumberFields, sfObject);       
    }else if(sfObject=='RecordType'){
        var sqlSelect = getSelectStatement(recordTypeFields, sfObject);
        var sqlInsert = getInsertStatement(recordTypeFields, sfObject);       
    }else if(sfObject=='Sales_Contract__c'){
        var sqlSelect = getSelectStatement(salesContractFields, sfObject);
        var sqlInsert = getInsertStatement(salesContractFields, sfObject);       
    }else if(sfObject=='User'){
        var sqlSelect = getSelectStatement(userFields, sfObject);
        var sqlInsert = getInsertStatement(userFields, sfObject);       
    }

    sfConnect.login(sfUserId, sfPassword, function(objLoginError, objLoginResponse){

    if (objLoginError){ 
        return console.error(objLoginError); 
    }
  
    var records = [];

    var query = sfConnect.query(sqlSelect)
        .on("record", function(record) {
            records.push(record);
        })
        .on("end", function() { 
        
            countSalesForceRecords = query.totalSize;
            fetchedSalesForceRecords = query.totalFetched;

            var arrRows = []; 
            for (var i=0; i<records.length; i++){
                var oneRow = Object.values(records[i]);  
                /*
                    sample oneRow value: [ { type: 'Account', url: '/services/data/v42.0/sobjects/Account/0013i00000FFCV8AAP' },
                                           '0013i00000FFCV8AAP', ... ]
                */
                oneRow.shift();     /* delete the unwanted first element of oneRow.  shift() does this in-place */
                // console.log(oneRow);
                arrRows.push(oneRow);
            }
        mySqlConnection.connect(function(err) {
            if (err){
                console.log('Could not connect to MySQL.\n');
                console.log('MySQL ERROR ' + err.errno + ': ' + err.code);
            }else{
                console.log('Successfully connected to MySQL.\n');
                mySqlConnection.query(sqlInsert, [arrRows], function(err, result){
                    if(err){
                        console.log('MySQL ERROR ' + err.errno + ': ' + err.code + '\n' + err.sqlMessage);
                    }else{
                        console.log('No. records in Sales Force           = ' + countSalesForceRecords);
                        console.log('No. records fetched from Sales Force = ' + fetchedSalesForceRecords);
                        console.log('No. records added to MySQL           = ' + result.affectedRows);
                        console.log('No. MySQL Warnings                   = ' + result.warningCount);
                        console.log('\r\n');
                        // console.log('MySQL Status:  ' + result.message.substr(1, 128) + '\r\n');
                        if(!(countSalesForceRecords == fetchedSalesForceRecords && fetchedSalesForceRecords == result.affectedRows)){
                            console.log('warning');
                        }    
                    }
                })
                mySqlConnection.end(); 
            }
            });
        })
      .on("error", function(err) {
        console.error(err);
      })
      .run({ autoFetch : true, maxFetch : 4000 }); // synonym of Query#execute();
 
});


/*   
  
sfConnect.describe('Account', function(err, meta){
    if(err){
        return console.error(err);
    }
    console.log('Label: ' + meta.label);
    console.log('No. of Fields: ' + meta.fields.length);
}) 
    
*/