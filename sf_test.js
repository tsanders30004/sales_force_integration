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
var mySqlConnection = mysql.createConnection({host: 'localhost', user: 'tsanders', password: 'rambuteau', database: 'junk'});

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
	 "ACH Credit Fee":'ach_credit_fee'
	,"BF ACH Discount Rate":'bfach_discount_rate'
	,"ACH Monthly Fee":'ach_monthly_fee'
	,"ACH NOC Fee":'ach_noc_fee'
	,"GW Per Transaction Fee":'ach_per_gw_trans_fee'
	,"ACH Return/Error Fee":'ach_return_error_fee'
	,"ACH Transaction Fee":'ach_transaction_fee'
	,"BF GW Discount Rate":'bluefin_gateway_discount_rate'
	,"File Transfer Monthly Fee":'file_transfer_monthly_fee'
	,"GW Monthly Fee":'gateway_monthly_fee'
	,"Group/Tag Fee":'group_tag_fee'
	,"GW Auth Decline Fee":'gw_per_auth_decline_fee'
	,"GW Per Transaction Fee":'per_transaction_fee'
	,"GW Credit Fee":'gw_per_credit_fee'
	,"GW Refund Fee":'gw_per_refund_fee'
	,"P2PE Transaction Fee":'gw_per_sale_fee'
	,"GW Token Fee":'gw_per_token_fee'
	,"GW Reissued Fee":'gw_reissued_fee'
	,"Misc Monthly Fee(s)":'misc_monthly_fees'
	,"P2PE Device Activated Fee":'p2pe_device_activated'
	,"P2PE Device Activating Fee":'p2pe_device_activating_fee'
	,"P2PE Device Stored Fee":'p2pe_device_stored_fee'
	,"P2PE Token Fee":'p2pe_encryption_fee'
	,"P2PE Token Flat Monthly Fee":'p2pe_monthly_flat_fee'
	,"One-Time Key Injection Fee":'one_time_key_injection_fees'
	,"P2PE Encryption Fee":'p2pe_tokenization_fee'
	,"PCI Scan Monthly Fee":'pci_scans_monthly_fee'
	,"PCI  Management Fee":'pci_compliance_fee'
	,"PCI Non-Compliance Fee":'pci_non_compliance_fee'
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
const fnSync=function(){
	//this will run alasql and proceed after all the salesforce stuff comes back
	var go=true;
	for(var i=0;i<arrTables.length;i++){
		if(!objData[arrTables[i]] || objData[arrTables[i]].length === 0){ 
			console.log('Waiting on records for ' + arrTables[i] + '...' );
			return false;
		}
	}
/*
	//simple join everything query
	var arrOutput = alasql('SELECT account.*,asset.*,bank.*,idnum.*,contract.* FROM ? AS account \
		JOIN ? as asset ON account.Id = asset.AccountId \
		JOIN ? as bank ON account.Id = bank.AccountId__c \
		JOIN ? as idnum ON account.Id = idnum.AccountId__c \
		JOIN ? as contract ON account.Id = contract.AccountId \
		JOIN ? as user ON account.OwnerId = user.Id \
		'
		 ,
	    [objData.Account,objData.Asset,objData.Bank_Account__c,objData.Identification_Number__c,objData.Contract,objData.User]);
*/

	var strQuery = 'SELECT \
	 		account.Id as acct_id, \
	 		account.Name as acct_name, \
	 		account.AccountNumber as accountnumber, \
	 		idnum.Name as mid_1, \
	 		idnum.Type__c as mid_1_type, \
	 		account.DBA_Name__c as dba_name, \
	 		contract.StartDate as date_agreement_signed, \
	 		idnum.Close_Date__c as closure_date, \
	 		account.Sic as sic, \
	 		user.Name as owner_name, \
	 		user.FirstName as owner_firstname, \
	 		user.LastName as owner_lastname, \
	 		contract.StartDate as bluefin_contract_start_date, \
	 		account.Industry as industry, \
	 		account.Revenue_Segment as segment, \
	 		account.ParentId as parent_acct_id, \
	 		contract.Hold_Billing__c as hold_billing, \
	 		contract.Billing_Hold_Release_Date__c as stop_billing, \
	 		contract.Billing_Preference__c as billing_situation, \
	 		contract.Billing_Frequency__c as billing_frequency, \
	 		account.LastModifiedDate as date_modified, \
	 		account.CreatedDate as date_updated ' 
	 		+ strSelectFees + 
	 	' FROM ? AS account \
		JOIN ? as asset ON account.Id = asset.AccountId \
		JOIN ? as bank ON account.Id = bank.AccountId__c \
		JOIN ? as idnum ON account.Id = idnum.AccountId__c \
		JOIN ? as contract ON account.Id = contract.AccountId \
		JOIN ? as user ON account.OwnerId = user.Id \
	';

	var arrOutput = alasql(strQuery,[objData.Account,objData.Asset,objData.Bank_Account__c,objData.Identification_Number__c,objData.Contract,objData.User]);
    var arrRows = [];
	// The in-memory JOIN is complete.
    
    // Write the output file.
	fnSave(arrOutput,'sfBilling.csv');

    // console.log(Object.values(arrOutput[0])); // eureka!  this is the object for the first element of arrOoutput converted to an array.
    
    console.log('WARNING:  for the moment, the number of rows to be written to the database is limited to three for testing...\n');
    for (var i=0; i<=2; i++){
        arrRows[i] = Object.values(arrOutput[i]);
    }
 
    fnInsert(arrRows);
 
    // Create a .CSV file that has the contents of the asset table.
    console.log('Asset table...\n');
    strQueryAsset = 'SELECT * FROM ? AS account';
    var arrOutputAsset = alasql(strQueryAsset,[objData.Account]);
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
		console.log('Processing '+arrRecords.length+' Asset Records');
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
	fs.writeFile(strFile, strData,(err) => { if (err) throw err; });
};

const fnInsert=function(arrRecords){
/*
    PURPOSE:  INSERT rows into the database.
    
    arrRecords is a two-dimensional array with the data to be added to the database;
    i.e., arrRecords[i][j] represents the jth column of the ith row.
*/

	console.log('Number for rows to add to the database:  ' + arrRecords.length);
    
    var sqlInsertAccount = 
        `INSERT INTO stg_cardconex_account( 
         acct_id, 
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
                console.log(results);
                console.log(results.message);
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