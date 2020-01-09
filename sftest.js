// org id:  00D3i000000Fc0i
// instance:  NA112
// https://bluefin.my.salesforce.com

// https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_SOQL.htm
// https://jsforce.github.io/document/#query


/*----====|| IMPORT LIBRARIES ||====----*/
// http://alasql.org/
const alasql = require('alasql');
const mysql = require('mysql');
const jsforce = require('jsforce');
const config  = require('./config');
const Papa = require('papaparse');
const fs = require('fs');

/*----====|| CREATE INSTANCES ||====----*/
var sfConnect = new jsforce.Connection();
var dbConnect = config.db.get;

/*----====|| SET GLOBAL VARIABLES ||====----*/
//to add a table
// 1. add the new table query to select the columns
// 2. add the table to the alaSQL join

//these are the quieries to populate the in memory tables from salesforce, no logic here just getting data to work with
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

//create the list of fields from this for select statement. to avoid copy pasta
var arrFees = Object.keys(objFeeMap);
var strSelectFees='';
for(var i=0;i<arrFees.length;i++){ strSelectFees = strSelectFees + ',asset.'+objFeeMap[arrFees[i]]; }

//this will store the results for example: objData.Account
//all of the tables are dynamically created from the queries
var objData={};

/*----====|| FUNCTIONS ||====----*/
const fnSync=function(){
	//this will run alasql and proceed after all the salesforce stuff comes back
	var go=true;
	for(var i=0;i<arrTables.length;i++){
		if(!objData[arrTables[i]] || objData[arrTables[i]].length === 0){ 
			console.log('still waiting on records for: ',arrTables[i]);
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
	 		idnum.Close_Date__c as clodure_date, \
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
	//console.log('alaSQL Query: '+strQuery);
	/*
	var strQuery='SELECT account.* \
		FROM ? AS account \
		JOIN ? as asset ON account.Id = asset.AccountId \
		JOIN ? as bank ON account.Id = bank.AccountId__c \
		JOIN ? as idnum ON account.Id = idnum.AccountId__c \
		JOIN ? as contract ON account.Id = contract.AccountId \
		JOIN ? as user ON account.OwnerId = user.Id \
		WHERE account.DBA_Name__c like "%Metro Chicago%" ';
	*/
	var arrOutput = alasql(strQuery,[objData.Account,objData.Asset,objData.Bank_Account__c,objData.Identification_Number__c,objData.Contract,objData.User]);

	// we did the big join, send to mysql
	console.log('records: ',arrOutput.length);
	console.log('result:',arrOutput);
	fnSave(arrOutput,'sfBilling.csv');
	//fnInsert(arrOutput);
}

const fnQuery=function(strTable){
	//this function runs the query for each object/table and ppulates the related data
	sfConnect.query(objQueries[strTable], function(objError, objResponse) {
	    if (objError) { return console.error(objError); }
	    if(objResponse.records){ 
	    	objData[strTable]=fnConvert(strTable,objResponse.records); 
	    	//if(strTable === 'Contract'){ console.log(objResponse.records); }
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
			//map all the fees
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
	console.log('joined records count:',arrRecords.length);
	//needs to be formatted in a way that can be inserted. mysql needs an array of values per row in the propper order, cant use objects
	var arrInsert=[];
	for(var i=0;i<arrRecords.length;i++){
		var objRow=[
			arrRecords[i]
		];
	}
	//the insert query
	/*
	[
		['val1,val2'],
		['val1',val2]
	]
	*/
	connection.query(
	    'insert into table (col1,col2) values ?'
	    ,[arrRecords]
	    ,function (objError, arrResults, objFields){
	      if(objError){ 
	      	//do this on error, error will be an object
	      	console.log(objError); 
	      }else{
	      	
	      }
	});
}

/*----====|| LOGIN TO SALESFORCE ||====----*/
sfConnect.login(config.sf.user, config.sf.password, function(objLoginError, objLoginResponse) {
  if (objLoginError) { return console.error(objLoginError); }
  // YOU CANNOT COMPARE FIELDS DIRECTLY IN THIS LANGUAGE, MUST USE SUB SELECTS :(
  // SO WE WILL JUST GRAB EACH TABLE WORTH OF INFO AND JOIN WITH ALASQL AND QUERY 
  
  /*----====|| IMPORT TABLES TO MEMORY ||====----*/
  for(var i=0;i<arrTables.length;i++){ fnQuery(arrTables[i]); }
  
});