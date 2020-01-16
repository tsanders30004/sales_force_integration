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

var arrTables=['Account'];  // Object.keys(objQueries);

var objData={};

const currentTimestamp = function(){
    // returns the current timestamp un YYYYMMDD_HHMMSS format.
    return new Date().toISOString().replace(/T/, '_').replace(/-/g, '').replace(/:/g, '').substring(0, 14);
}

const fnSync=function(){
    
	var go=true;
	for(var i=0;i<arrTables.length;i++){
		if(!objData[arrTables[i]] || objData[arrTables[i]].length === 0){ 
			console.log('Waiting on records for ' + arrTables[i] + '...' );
			return false;
		}
	}
                   
    var strQuery = 'SELECT AccountNumber,Site,AccountSource,Account_Status__c,Active_ACH_IDs__c,Active_Acquiring_IDs__c,Active_Encryption_IDs__c,Active_Gateway_IDs__c,Active_Services__c,Additional_Documentation_Needed__c,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Billing_Contact_Email_Addresses__c,Business_Start_Date__c,CreatedById,CreatedDate,Customer_Number__c,DBA_Name__c,Description,Exemption_No__c,Id,Industry,IsPartner,Is_501c3__c,LastActivityDate,LastModifiedById,LastModifiedDate,Lead_Type__c,Legacy_ID__c,Legacy_Source__c,Max_Contract_End_Date__c,Months_In_Business__c,Name,NumberOfEmployees,Open_Opportunities__c,Open_Opportunity_Amount__c,OrganizationID__c,OwnerId,ParentId,Partnership_Type__c,Partner_Service_Instructions__c,Phone,PhotoUrl,RecordTypeId,Revenue_Segment__c,ShippingAddress,ShippingCity,ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Sic,SicDesc,Type,Unique_Count__c,Website FROM ? AS account';

	var arrOutput = alasql(strQuery,[objData.Account]);
    
    var arrRows = [];
    
    // Write the output file.
	fnSave(arrOutput,'sfBilling.csv');
    
    for (var i=0; i<arrOutput.length; i++){
        arrRows[i] = Object.values(arrOutput[i]);
    }
 
    // console.log(arrRows[0]);
    
    fnInsert(arrRows, 'account');
 
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


    strQueryAsset                                = 'SELECT * FROM ? AS asset';
    var arrOutputAsset                           = alasql(strQueryAsset,[objData.Asset]);
    fnSave(arrOutputAsset,'sfAsset.csv');
    */

}

const fnQuery=function(strTable){
	//this function runs the query for each object/table and populates the related data
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



const fnInsert=function(arrRecords, tableName){
/*
    PURPOSE:  INSERT rows into the database.
    
    arrRecords is a two-dimensional array with the data to be added to the database;
    i.e., arrRecords[i][j] represents the jth column of the ith row.
*/

	console.log('Number for rows to add to the database:  ' + arrRecords.length);

    // console.log(arrRecords);

    var sqlInsertAccount = 
        `INSERT INTO account(AccountNumber,Site,AccountSource,Account_Status__c,Active_ACH_IDs__c,Active_Acquiring_IDs__c,Active_Encryption_IDs__c,Active_Gateway_IDs__c,Active_Services__c,Additional_Documentation_Needed__c,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Billing_Contact_Email_Addresses__c,Business_Start_Date__c,CreatedById,CreatedDate,Customer_Number__c,DBA_Name__c,Description,Exemption_No__c,Id,Industry,IsPartner,Is_501c3__c,LastActivityDate,LastModifiedById,LastModifiedDate,Lead_Type__c,Legacy_ID__c,Legacy_Source__c,Max_Contract_End_Date__c,Months_In_Business__c,Name,NumberOfEmployees,Open_Opportunities__c,Open_Opportunity_Amount__c,OrganizationID__c,OwnerId,ParentId,Partnership_Type__c,Partner_Service_Instructions__c,Phone,PhotoUrl,RecordTypeId,Revenue_Segment__c,ShippingAddress,ShippingCity,ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Sic,SicDesc,Type,Unique_Count__c,Website
         ) VALUES ?`;
        
/*    var sqlInsertAccount = 'INSERT INTO ' + tableName + '(acct_id) VALUES ?';*/
    
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