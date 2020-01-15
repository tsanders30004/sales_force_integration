// instance:  NA112
// https://bluefin.my.salesforce.com
// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SOQL.htm
// https://jsforce.github.io/document/#query


// Libraries
const alasql  = require('alasql');  // http://alasql.org/
const mysql   = require('mysql');
const jsforce = require('jsforce');
const config  = require('./config');
const Papa    = require('papaparse');
const fs      = require('fs');

// Sales Force
var sfConnect = new jsforce.Connection();

// MySQL
var dbConnect       = config.db.get;  // what is this for?

/* need to figure out how to retrieve this data from the config file */
var mySqlConnection = mysql.createConnection({host: 'localhost', user: 'tsanders', password: 'rambuteau', database: 'sales_force'});

//  Global Variables
//  To add a table:  
//  *   Add the new table query to SELECT the columns
//  *   Add the table to the alaSQL JOIN

//  These are the queries to populate the in memory-tables from Sales Force; includes no logic.
var objQueries={
	 "Account":'SELECT AccountNumber,Site,AccountSource,Account_Status__c,Active_ACH_IDs__c,Active_Acquiring_IDs__c,Active_Encryption_IDs__c,Active_Gateway_IDs__c,Active_Services__c,Additional_Documentation_Needed__c,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Billing_Contact_Email_Addresses__c,Business_Start_Date__c,CreatedById,CreatedDate,Customer_Number__c,DBA_Name__c,Description,Exemption_No__c,Id,Industry,IsPartner,Is_501c3__c,LastActivityDate,LastModifiedById,LastModifiedDate,Lead_Type__c,Legacy_ID__c,Legacy_Source__c,Max_Contract_End_Date__c,Months_In_Business__c,Name,NumberOfEmployees,Open_Opportunities__c,Open_Opportunity_Amount__c,OrganizationID__c,OwnerId,ParentId,Partnership_Type__c,Partner_Service_Instructions__c,Phone,PhotoUrl,RecordTypeId,Revenue_Segment__c,ShippingAddress,ShippingCity,ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Sic,SicDesc,Type,Unique_Count__c,Website FROM Account'
	,"Bank_Account__c":'SELECT Bank_Name__c,ABA__c,AccountId__c,Account_Type__c,ACH_Debit_Account_Name__c,ACH_Descriptor__c,Bank_Account_Number__c,Bank_Account_Type__c,Bank_City__c,Bank_Contact_Name__c,Bank_Phone__c,Bank_Postal_Code__c,Bank_State__c,Bank_Street_Address__c,Business_Person_Named_on_teh_account__c,CreatedById,CreatedDate,Id,LastModifiedDate,Name FROM Bank_Account__c'
	,"Identification_Number__c":'SELECT AccountId__c,Category__c,Close_Date__c,CreatedById,CreatedDate,Id,LastModifiedById,LastModifiedDate,Name,OwnerId,RecordTypeId,Start_Date__c,Status__c,Type__c,Unique_ID__c,Warnings__c FROM Identification_Number__c'
	,"Contract":'SELECT AccountId,ActivatedById,ActivatedDate,Additional_Documentation_Needed__c,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Billing_AccountId__c,Billing_Frequency__c,Billing_Month__c,Billing_Preference__c,Collection_Method__c,CompanySignedDate,CompanySignedId,ContractNumber,ContractTerm,CreatedById,CreatedDate,CustomerSignedId,CustomerSignedTitle,Description,EndDate,ia_crm__Ship_to__c,Id,IsDeleted,LastActivityDate,LastApprovedDate,LastModifiedById,LastModifiedDate,OpportunityId__c,OwnerExpirationNotice,OwnerId,Pricebook2Id,RecordTypeId,Revenue_Segment__c,ShippingCity,ShippingCountry,ShippingCountryCode,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,SpecialTerms,StartDate,Status,StatusCode,Billing_Hold_Reason__c,Billing_Hold_Release_Date__c,Hold_Billing__c FROM Contract'
	,"Asset":'SELECT AccountId,AssetLevel,ContractId__c,CreatedById,CreatedDate,Description,Fee_Amount_Text__c,Fee_Amount__c,Fee_Group__c,Fee_Name__c,Id,Identification_NumberId__c,ID_Number_Text__c,InstallDate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,Price,Product2Id,ProductCode,PurchaseDate,Quantity,Quote_Line_ItemId__c,SerialNumber,Status,UsageEndDate FROM Asset'
	,"RecordType":'SELECT BusinessProcessId,CreatedById,CreatedDate,Description,DeveloperName,Id,IsActive,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SobjectType FROM RecordType'
	,"User":'SELECT Id,Name,FirstName,LastName FROM User'
};

var arrTables=Object.keys(objQueries);

var objFeeMap={
	 "ACH Credit Fee":                  'ach_credit_fee'
	,"BF ACH Discount Rate":            'bfach_discount_rate'
	,"ACH Monthly Fee":                 'ach_monthly_fee'
	,"ACH NOC Fee":                     'ach_noc_fee'
	,"GW Per Transaction Fee":          'ach_per_gw_trans_fee'
	,"ACH Return/Error Fee":            'ach_return_error_fee'
	,"ACH Transaction Fee":             'ach_transaction_fee'
	,"BF GW Discount Rate":             'bluefin_gateway_discount_rate'
	,"File Transfer Monthly Fee":       'file_transfer_monthly_fee'
	,"GW Monthly Fee":                  'gateway_monthly_fee'
	,"Group/Tag Fee":                   'group_tag_fee'
	,"GW Auth Decline Fee":             'gw_per_auth_decline_fee'
	,"GW Per Transaction Fee":          'per_transaction_fee'
	,"GW Credit Fee":                   'gw_per_credit_fee'
	,"GW Refund Fee":                   'gw_per_refund_fee'
	,"P2PE Transaction Fee":            'gw_per_sale_fee'
	,"GW Token Fee":                    'gw_per_token_fee'
	,"GW Reissued Fee":                 'gw_reissued_fee'
	,"Misc Monthly Fee(s)":             'misc_monthly_fees'
	,"P2PE Device Activated Fee":       'p2pe_device_activated'
	,"P2PE Device Activating Fee":      'p2pe_device_activating_fee'
	,"P2PE Device Stored Fee":          'p2pe_device_stored_fee'
	,"P2PE Token Fee":                  'p2pe_encryption_fee'
	,"P2PE Token Flat Monthly Fee":     'p2pe_monthly_flat_fee'
	,"One-Time Key Injection Fee":      'one_time_key_injection_fees'
	,"P2PE Encryption Fee":             'p2pe_tokenization_fee'
	,"PCI Scan Monthly Fee":            'pci_scans_monthly_fee'
	,"PCI  Management Fee":             'pci_compliance_fee'
	,"PCI Non-Compliance Fee":          'pci_non_compliance_fee'
};

//  Create the list of fields from this for the SELECT statement.
var arrFees = Object.keys(objFeeMap);
var strSelectFees='';
for(var i=0;i<arrFees.length;i++){
        strSelectFees = strSelectFees + ',asset.' + objFeeMap[arrFees[i]];
    }

//  this will store the results for example: objData.Account
//  all of the tables are dynamically created from the queries
var objData={};

// Functions

const currentTimestamp = function(){
    // returns the current timestamp un YYYYMMDD_HHMMSS format.
    return new Date().toISOString().replace(/T/, '_').replace(/-/g, '').replace(/:/g, '').substring(0, 14);
}

const fnSync=function(){
	/*
        PURPOSE:  perform the in-memory table JOIN, write the output file, and update the database.
    */
    
	var go=true;
	for(var i=0;i<arrTables.length;i++){
		if(!objData[arrTables[i]] || objData[arrTables[i]].length === 0){ 
			console.log('Waiting on records for ' + arrTables[i] + '...' );
			return false;
		}
	}

	var strQuery = 'SELECT \
	 		account.Id                              AS acct_id, \
            account.Legacy_ID__c                    AS legacy_id, \
	 		account.Name                            AS acct_name, \
	 		account.AccountNumber                   AS accountnumber, \
	 		idnum.Name                              AS mid_1, \
	 		idnum.Type__c                           AS mid_1_type, \
	 		account.DBA_Name__c                     AS dba_name, \
	 		contract.StartDate                      AS date_agreement_signed, \
	 		idnum.Close_Date__c                     AS closure_date, \
	 		account.Sic                             AS sic, \
	 		user.Name                               AS owner_name, \
	 		user.FirstName                          AS owner_firstname, \
	 		user.LastName                           AS owner_lastname, \
	 		contract.StartDate                      AS bluefin_contract_start_date, \
	 		account.Industry                        AS industry, \
	 		account.Revenue_Segment                 AS segment, \
	 		account.ParentId                        AS parent_acct_id, \
	 		contract.Hold_Billing__c                AS hold_billing, \
	 		contract.Billing_Hold_Release_Date__c   AS stop_billing, \
	 		contract.Billing_Preference__c          AS billing_situation, \
	 		contract.Billing_Frequency__c           AS billing_frequency, \
	 		account.LastModifiedDate                AS date_modified, \
	 		account.CreatedDate                     AS date_updated ' 
	 		+ strSelectFees + 
      ' FROM ?                                      AS account \
		JOIN ?                                      AS asset ON account.Id = asset.AccountId \
		JOIN ?                                      AS bank ON account.Id = bank.AccountId__c \
		JOIN ?                                      AS idnum ON account.Id = idnum.AccountId__c \
		JOIN ?                                      AS contract ON account.Id = contract.AccountId \
		JOIN ?                                      AS user ON account.OwnerId = user.Id \
	';
                                                          
	var arrOutput = alasql(strQuery,[objData.Account,objData.Asset,objData.Bank_Account__c,objData.Identification_Number__c,objData.Contract,objData.User]);
    
    var arrRows = [];
	// The in-memory JOIN is complete.
    
    // Write the output file.
	fnSave(arrOutput,'sfBilling.csv');

    // console.log(Object.values(arrOutput[0])); // eureka!  this is the object for the first element of arrOoutput converted to an array.
    
    for (var i=0; i<arrOutput.length; i++){
        arrRows[i] = Object.values(arrOutput[i]);
    }
 
    // console.log(arrRows[0]);
    
    fnInsert(arrRows);
 
    // Create a .CSV file that has the contents of the other tables - for debugging only.

    /*
    console.log('Exporting all tables for debugging...\n');
    
    strQueryAccount                              = 'SELECT * FROM ? AS account';
    var arrOutputAccount                         = alasql(strQueryAccount,[objData.Account]);
    fnSave(arrOutputAccount,'sfAccount.csv');
    
    strQueryAsset                                = 'SELECT AccountId,AssetLevel,ContractId__c,CreatedById,CreatedDate,Description,Fee_Amount_Text__c,Fee_Amount__c,Fee_Group__c,Fee_Name__c,Id,Identification_NumberId__c,ID_Number_Text__c,InstallDate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,Price,Product2Id,ProductCode,PurchaseDate,Quantity,Quote_Line_ItemId__c,SerialNumber,Status,UsageEndDate FROM ? AS asset';
    var arrOutputAsset                           = alasql(strQueryAsset,[objData.Asset]);
    // console.log(arrOutputAsset);
    fnSave(arrOutputAsset,'sfAsset.csv');
    
    strQueryBankAccount                          = 'SELECT * FROM ? AS bankAccount';
    var arrOutputBankAccount                     = alasql(strQueryBankAccount,[objData.Bank_Account__c]);
    fnSave(arrOutputBankAccount,'sfBankAccount.csv');    

    strQueryContract                             = 'SELECT * FROM ? AS contract';
    var arrOutputContract                        = alasql(strQueryContract,[objData.Contract]);
    fnSave(arrOutputContract,'sfContract.csv'); 
    
    strQueryIdentificationNumber                 = 'SELECT * FROM ? AS identificationNumber';
    var arrOutputIdentificationNumber            = alasql(strQueryIdentificationNumber,[objData.Identification_Number__c]);
    fnSave(arrOutputIdentificationNumber,'sfBankIdentificationNumber.csv');  
 
    strQueryRecordType                           = 'SELECT * FROM ? AS recordType';
    var arrOutputRecordType                      = alasql(strQueryRecordType,[objData.RecordType]);
    fnSave(arrOutputRecordType,'sfRecordType.csv'); 
    
    strQueryUser                                 = 'SELECT * FROM ? AS user';
    var arrOutputUser                            = alasql(strQueryUser,[objData.User]);
    fnSave(arrOutputUser,'sfUser.csv'); 
    */

    strQueryAsset                                = 'SELECT * FROM ? AS asset';
    var arrOutputAsset                           = alasql(strQueryAsset,[objData.Asset]);
    // console.log(arrOutputAsset);
    fnSave(arrOutputAsset,'sfAsset.csv');

}

const fnQuery=function(strTable){
	//this function runs the query for each object/table and ppulates the related data
	sfConnect.query(objQueries[strTable], function(objError, objResponse) {
	    if (objError) { return console.error(objError); }
	    if(objResponse.records){ 
	    	objData[strTable]=fnConvert(strTable,objResponse.records); 
	    	fnSync(); 
	    }
	    else{console.log('still waiting on records for '+ strTable)}
	});
};

const fnConvert=function(strTable,arrRecords){
	var arrResults=[];
	//change the asset - fee records
	if(strTable === 'Asset'){
		console.log('processing '+arrRecords.length+' asset records');
		for(var i=0;i<arrRecords.length;i++){
			var objRecord=arrRecords[i];
			for( var ii=0;ii<arrFees.length;ii++){
				if(objRecord.Fee_Name__c == arrFees[ii]){
					objRecord[objFeeMap[arrFees[ii]]] = objRecord.Fee_Amount__c; 
				}
				else{ objRecord[objFeeMap[arrFees[ii]]] = 0; }
			}
			arrResults.push(objRecord);
		}
	}else{
		arrResults=arrRecords;
	}
	return arrResults;
}

const fnSave=function(arrData,strFile){
	console.log('saving file: ',strFile);
	//https://www.papaparse.com/docs#json-to-csv
	var strData = Papa.unparse(arrData);

    /* 
        Redefine the output file to have an embedded timestamp.
        Assumes the input file has a three-character extension.
        Example:  sfBilling.csv becomes sfBilling_YYYYMMDD_HHMMSS.csv
    */
    var strOutFile = strFile.substring(0, strFile.indexOf('.'))
         .concat('_')
         .concat(currentTimestamp())
         .concat('.')
         .concat(strFile.substring(strFile.length - 3));
         
	fs.writeFile(strOutFile, strData,(err) => { if (err) throw err; });         
};



const fnInsert=function(arrRecords){
/*
    PURPOSE:  INSERT rows into the database.
    
    arrRecords is a two-dimensional array with the data to be added to the database;
    i.e., arrRecords[i][j] represents the jth column of the ith row.
*/

	console.log('Number for rows to add to the database:  ' + arrRecords.length);
    var sqlInsertAccount = 
        `INSERT INTO test_cardconex_account( 
         acct_id, 
         legacy_id,
         acct_name, 
         accountnumber, 
         mid_1, 
         mid_1_type, 
         dba_name, 
         date_agreement_signed, 
         closure_date, 
         sic, 
         owner_name, 
         owner_firstname, 
         owner_lastname, 
         bluefin_contract_start_date, 
         industry, 
         segment, 
         parent_acct_id, 
         hold_billing, 
         stop_billing, 
         billing_situation, 
         billing_frequency, 
         date_modified, 
         date_updated, 
         ach_credit_fee, 
         bfach_discount_rate, 
         ach_monthly_fee, 
         ach_noc_fee, 
         per_transaction_fee, 
         ach_return_error_fee, 
         ach_transaction_fee, 
         bluefin_gateway_discount_rate, 
         file_transfer_monthly_fee, 
         gateway_monthly_fee, 
         group_tag_fee, 
         gw_per_auth_decline_fee, 
         gw_per_credit_fee, 
         gw_per_refund_fee, 
         gw_per_sale_fee, 
         gw_per_token_fee, 
         gw_reissued_fee, 
         misc_monthly_fees, 
         p2pe_device_activated, 
         p2pe_device_activating_fee, 
         p2pe_device_stored_fee, 
         p2pe_encryption_fee, 
         p2pe_monthly_flat_fee, 
         one_time_key_injection_fees, 
         p2pe_tokenization_fee, 
         pci_scans_monthly_fee, 
         pci_compliance_fee, 
         pci_non_compliance_fee
         ) VALUES ?`;
        
    mySqlConnection.connect(function(err) {
        if (err){
            console.log('Could not connect to MySQL.\n');
            console.log('MySQL ERROR ' + err.errno + ': ' + err.code);
        } else{
            console.log('Successfully connected to MySQL.\n');

            mySqlConnection.query(sqlInsertAccount, [arrRecords], function(err, results, fields){
            if(err){
                console.log('MySQL ERROR ' + err.errno + ': ' + err.code + '\n' + err.sqlMessage);
            }else{
                console.log('MySQL Status:  ' + results.message.substr(1, 128));
            }
            
            
            });
            mySqlConnection.end();
        }
    });
    

}

// Log in to Sales Force
sfConnect.login(config.sf.user, config.sf.password, function(objLoginError, objLoginResponse) {
  if (objLoginError) { 
    return console.error(objLoginError); 
  }
  // YOU CANNOT COMPARE FIELDS DIRECTLY IN THIS LANGUAGE, MUST USE SUB SELECTS :(
  // SO WE WILL JUST GRAB EACH TABLE WORTH OF INFO AND JOIN WITH ALASQL AND QUERY 
  
// import tables to memory.
  for(var i=0; i<arrTables.length; i++){ 
    fnQuery(arrTables[i]); 
  }
  
});