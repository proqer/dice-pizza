const readline = require('readline');
const database = require('./server/database');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

rl.question(
    "You are going to give admin access to user. Type user's nickname:",
    async (answer) => {
        await database.query(
            'UPDATE user SET user_is_admin = 1 WHERE user_login = ?',
            answer
        );
        console.log('Done!', answer, 'is now an administrator');
        rl.close();
    }
);
