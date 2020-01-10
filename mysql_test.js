var mysql      = require('mysql');                               /* to install:   npm install --save mysql            */
var mysqlConn = mysql.createConnection({host: "localhost", user: "tsanders", password: "rambuteau"});
  
var mysqlStatement = 'SELECT current_timestamp, current_date';

console.log('node.js MySQL Demonstration\n');
console.log('MySQL Statement' + mysqlStatement + '\n');

mysqlConn.connect(function(err) {
    if (err){
        console.log('Count not connect to MySQL.\n');
        console.log('MySQL ERROR ' + err.errno + ': ' + err.code);
    } else{
        console.log('Successfully connected to MySQL.\n');
        mysqlConn.query(mysqlStatement, function(err, results, fields){
       console.log(results);
       
       /* use the following if necessary to show more information */
       // console.log(fields);
    });
    mysqlConn.end();
    }
});

