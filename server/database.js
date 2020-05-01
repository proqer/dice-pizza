const mysql = require('promise-mysql');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    database: 'pizza',
    connectionLimit: 4,
});

module.exports = pool;
