
const config  = require('./config'); 
const mysql = require('mysql');
// https://github.com/dmanjunath/node-redshift#readme
const red = require('node-redshift');
//https://momentjs.com/



var arrMySQL=[];
var arrRedShift =[];
var arrDiff = [];

// query for the mysql data
/*
	SELECT MIN(id),MAX(id),COUNT(*)
	FROM DaaS.Transaction
	WHERE EndDate BETWEEN "20191111" AND "20191111";
*/
var connection = config.db.get;
connection.query(
	'SELECT DATE_FORMAT(EndDate, "%Y-%m-%d") as dat,COUNT(*) as tot,COUNT(DISTINCT Id),MIN(Id),MAX(Id) \
		FROM DaaS.Transaction \
		WHERE PartnerId = 1 \
		GROUP BY 1 \
		ORDER BY 1'
	    ,[]
	    ,function (objError, arrResults, objFields){
	      if(objError){ 
	      	//do this on error, error will be an object
	      	console.log(objError); 
	      }else{
	      	arrMySQL=arrResults;
	      	fnSync();
	      }
	});


// query the redshift data
var redshiftClient = new Redshift(config.redhshift);
redshiftClient.rawQuery('SELECT DATE_TRUNC("day", EndDate) as dat,COUNT(*) as tot,COUNT(DISTINCT Id),MIN(Id),MAX(Id) \
	FROM DaaS.Transaction \
	WHERE PartnerId = 1 \
	GROUP BY 1 \
	ORDER BY 1;', function(err, arrData){
  if(err) throw err;
  else{
    console.log(arrData);
    arrRedShift=arrData;
    fnSync();
  }
});

const fnSync=function(){
	
	if(arrMySQL.length > 1 && arrRedShift.lengtg > 1){
		// compare the 2
		for(var i=0;i<arrMySQL.length;i++){
			for( var ii=0; ii<arrRedShift.length;ii++){
				if( arrMySQL[i].dat === arrRedShift[ii].dat ){
					//found the matching date, compare the values
					arrDiff.push({
						 "Date": arrMySQL[i].dat
						,"MySql": arrMySQL[i].tot
						,"RedShift": arrRedShift[ii].tot
						,"Diff": arrMySQL[i].tot-arrRedShift[ii].tot
					});
				}
			}
		}
	}
	// output results
	console.log(arrDiff);
}





