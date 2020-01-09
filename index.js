/*
	to get started: 
	1. install nodejs with command line support
	2. extract this to a directory
	3. in this directory run "npm install"
	4. edit the file for the config and query needed
	5. run it by "node index.js"

	let me know if you need any help
*/


const config  = require('./config'); 

//this requires you run  "npm install" once
// https://github.com/mysqljs/mysql
const mysql = require('mysql');
// https://www.papaparse.com/
const Papa = require('papaparse');
const fs = require('fs');

// this runs the connection that is setup in config.js makes it easy to reuse in the rest. 
var connection = config.db.get;


//function to be called , wraps the query so it can be easily run for each row on an intentional timeline
const fnAct=function(objRow){
	//here's a basic query, each of the ? lines up with the array of variables afterwards
	connection.query(
	    'insert into table (val) values ( ? )'
	    ,[objRow.field]
	    ,function (objError, arrResults, objFields){
	      if(objError){ 
	      	//do this on error, error will be an object
	      	console.log(objError); 
	      }else{
	      	//do this with results. they will be in objResults a collection (array of objects) = [ {"field":value,"field":value} ]
	      	// to iterate in results
	      	// for(var i=0;i<arrResults.length;i++){ console.log( arrResults[i].fieldnamehere ); }
	      }
	});
}

//get a csv file, put it into a collection
fs.readFile('filename here', 'utf8', function(err, strResults) {
   Papa.parse(  strResults, {
    delimiter: ',',
    header:true,
    complete: function(objResults) {
      //run a function for each row in the file with an interval of pausing, in milliseconds
      var objGo = setInterval(function(){ 
        if(arrIterate.length > 0){
          fnAct(objResults.data.pop());
        }else{
          clearInterval(objGo);
        }
      }, 1000);

    }
  });
});