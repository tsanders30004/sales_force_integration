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

var sfUserId = config.sf.user;
var sfPassword = config.sf.password;

/* main */
    sfConnect.login(sfUserId, sfPassword, function(objLoginError, objLoginResponse){

    if (objLoginError){ 
        return console.error(objLoginError); 
    }
    
    var accountSelect = 'SELECT AccountNumber,Site,AccountSource,Account_Status__c,Active_ACH_IDs__c,Active_Acquiring_IDs__c,Active_Encryption_IDs__c,Active_Gateway_IDs__c,Active_Services__c,Additional_Documentation_Needed__c,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Billing_Contact_Email_Addresses__c,Business_Start_Date__c,CreatedById,CreatedDate,Customer_Number__c,DBA_Name__c,Description,Exemption_No__c,Id,Industry,IsPartner,Is_501c3__c,LastActivityDate,LastModifiedById,LastModifiedDate,Lead_Type__c,Legacy_ID__c,Legacy_Source__c,Max_Contract_End_Date__c,Months_In_Business__c,Name,NumberOfEmployees,Open_Opportunities__c,Open_Opportunity_Amount__c,OrganizationID__c,OwnerId,ParentId,Partnership_Type__c,Partner_Service_Instructions__c,Phone,PhotoUrl,RecordTypeId,Revenue_Segment__c,ShippingAddress,ShippingCity,ShippingCountry,ShippingCountryCode,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStateCode,ShippingStreet,Sic,SicDesc,Type,Unique_Count__c,Website FROM Account';
    
    var sqlInsertAccount = "INSERT INTO test(a, b, c) VALUES ?";
    
    var records = [];
    
/*     sfConnect.query(accountAccount2, function(err, result) {
        if (err) { return console.error(err); }

        for(var i=0; i<result.records.length; i++){
            console.log(result.records[i].Id);   

        }
        
        console.log("total : " + result.totalSize);
        console.log("fetched : " + result.records.length);
    }); */
 
/*     sfConnect.describe('Account', function(err, meta){
        if(err){
            return console.error(err);
        }
        console.log('Label: ' + meta.label);
        console.log('No. of Fields: ' + meta.fields.length);
    }) */
    
/*     sfConnect.query(accountSelect, function(err, result) {
        if (err) { return console.error(err); }
        console.log("total : " + result.totalSize);
        console.log("fetched : " + result.records.length);
        console.log("done ? : " + result.done);
        if (!result.done) {
        // you can use the locator to fetch next records set.
        // Connection#queryMore()
        console.log("next records URL : " + result.nextRecordsUrl);
        }
    }); */
    

    // var query = sfConnect.query(accountSelect)         
    var query = sfConnect.query('SELECT Id, AccountNumber, Account_Status__c FROM Account')
      .on("record", function(record) {
        records.push(record);
      })
      .on("end", function() {
        console.log("total in database : " + query.totalSize);
        console.log("total fetched     : " + query.totalFetched);
        console.log("records.length    : " + records.length); 
        
        // console.log('records = ' + records);
        // console.log('Object.keys(records)      = ' + Object.keys(records));  no good
        // console.log('Object.keys(records[0])   = ' + Object.keys(records[0]));  attributes,Id,AccountNumber,Account_Status__c
        // console.log('Object.values(records)    = ' + Object.values(records));   [object Object],[object Object],
        console.log('Object.values(records[0]) = ' + Object.values(records[0]));
        console.log('records[0]                = ' + records[0]);
        
        var arrRows = []; 
        
        for (var i=0; i<5; i++){
            var oneRow = Object.values(records[i]);
            console.log(oneRow);
            oneRow.shift();
            console.log(oneRow);
            // console.log('oneRow = ' + oneRow);
            // console.log('oneRow.length = ' + oneRow.length);
            arrRows.push(oneRow);
        }
        console.log('arrRows = ' + arrRows);
        console.log('arrRows.length = ' + arrRows.length);
        console.log('arrRows[0][0] = ' + arrRows[0][0]);
        console.log('arrRows[0][0] = ' + arrRows[0][1]);
        console.log('arrRows[0][0] = ' + arrRows[0][2]);
        console.log('arrRows[1][0] = ' + arrRows[1][0]);
        console.log('arrRows[1][0] = ' + arrRows[1][1]);
        console.log('arrRows[1][0] = ' + arrRows[1][2]);
        mySqlConnection.connect(function(err) {
            if (err){
                console.log('Could not connect to MySQL.\n');
                console.log('MySQL ERROR ' + err.errno + ': ' + err.code);
            }else{
                console.log('Successfully connected to MySQL.\n');
                mySqlConnection.query(sqlInsertAccount, [arrRows], function(err, result){
                    if(err){
                        console.log(err);
                    }
                    
                    console.log('record inserted.');
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