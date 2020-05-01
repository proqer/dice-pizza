const path = require('path');
const crypto = require('crypto');
const express = require('express');
const bodyParser = require('body-parser');
const passport = require('passport');
const passportLocal = require('passport-local');
const expressSession = require('express-session');
const database = require('./database');
const ensureGuest = require('./middlewares/ensureGuest');
const ensureAuthenticated = require('./middlewares/ensureAuthenticated');

passport.use(
    new passportLocal(async (username, password, done) => {
        try {
            const rows = await database.query(
                'SELECT * FROM user WHERE user_login = ? LIMIT 1',
                username
            );
            if (!rows.length) {
                done(null, false);
                return;
            }
            const { user_password, user_password_salt } = rows[0];
            const hashedPassword = crypto
                .pbkdf2Sync(password, user_password_salt, 2048, 64, 'sha512')
                .toString('hex');
            if (user_password !== hashedPassword) {
                done(null, false);
                return;
            }
            done(null, rows[0]);
        } catch (e) {
            done(e);
        }
    })
);

passport.serializeUser((user, cb) => {
    cb(null, user.user_id);
});
passport.deserializeUser(async (id, cb) => {
    try {
        const [row] = await database.query(
            'SELECT * FROM user WHERE user_id = ? LIMIT 1',
            id
        );
        cb(null, row);
    } catch (e) {
        cb(e);
    }
});

const app = express();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, '../static')));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));
app.use(
    expressSession({
        name: 'session',
        secret: 'totallysecretshit',
        resave: false,
        saveUninitialized: false,
    })
);
app.use(passport.initialize());
app.use(passport.session());

app.use((req, res, next) => {
    res.locals.auth = req.isAuthenticated();
    res.locals.user = req.user;
    res.locals.path = req.path;
    res.locals.cart = req.session.cart || [];
    next();
});

app.get('/', (req, res) => {
    database
        .query(
            `SELECT * FROM pizza
			 	INNER JOIN pizza_title ON pizza.pizza_title_id = pizza_title.pizza_title_id
			 GROUP BY pizza.pizza_title_id`
        )
        .then((rows) => {
            res.render('index', { pizzas: rows });
        });
});

app.get('/pizza/:id', (req, res) => {
    database
        .query(
            `SELECT * FROM pizza
				INNER JOIN pizza_title ON pizza.pizza_title_id = pizza_title.pizza_title_id
				INNER JOIN pizza_size ON pizza.pizza_size_id = pizza_size.pizza_size_id
			 WHERE pizza.pizza_title_id = ?`,
            req.params.id
        )
        .then((result) => {
            database
                .query(
                    `SELECT * FROM pizza_ingredient
					 	INNER JOIN ingredient ON pizza_ingredient.ingredient_id = ingredient.ingredient_id
					 WHERE pizza_ingredient.pizza_title_id = ?`,
                    req.params.id
                )
                .then((result2) => {
                    rows = result;
                    rows2 = result2;
                    const pizza_info = {
                        title_id: rows[0].pizza_title_id,
                        name: rows[0].pizza_name,
                        description: rows[0].pizza_description,
                        sizes: rows.map((row) => ({
                            id: row.pizza_size_id,
                            value: row.size_value,
                        })),
                        prices: rows.map((row) => row.pizza_price),
                        ingredients: rows2.map((row) => row.ingredient_name),
                    };

                    res.render('pizza', { pizza: pizza_info });
                });
        });
});

app.get('/login', ensureGuest, (req, res) => {
    res.render('login');
});

app.post('/login', ensureGuest, (req, res, next) => {
    passport.authenticate('local', (err, user, info) => {
        if (err) {
            next(err);
            return;
        }
        if (!user) {
            res.render('login', {
                error: 'Логин и/или пароль введены неверно',
            });
            return;
        }
        req.logIn(user, (err) => {
            if (err) {
                next(err);
                return;
            }
            res.redirect('/');
        });
    })(req, res, next);
});

app.get('/register', ensureGuest, (req, res) => {
    res.render('register');
});

app.post('/register', ensureGuest, (req, res) => {
    const errors = [];

    if (!req.body.name) {
        errors.push('Неверно введено имя');
    }
    if (!req.body.surname) {
        errors.push('Неверно введена фамилия');
    }
    if (!req.body.patronymic) {
        errors.push('Неверно введено отчество');
    }
    if (!req.body.phone) {
        errors.push('Неверно введен номер телефона');
    }
    if (!req.body.address) {
        errors.push('Наверно введен адрес');
    }
    if (!req.body.login) {
        errors.push('Неверно введен логин');
    }
    if (!req.body.password) {
        errors.push('Неверно введен пароль');
    }
    if (errors.length > 0) {
        res.render('register', {
            errors,
            name: req.body.name,
            surname: req.body.surname,
            patronymic: req.body.patronymic,
            phone: req.body.phone,
            address: req.body.address,
            login: req.body.login,
        });
        return;
    }

    const salt = crypto.randomBytes(64).toString('hex');
    const hashedPassword = crypto
        .pbkdf2Sync(req.body.password, salt, 2048, 64, 'sha512')
        .toString('hex');
    database
        .query(
            `INSERT INTO user
		( 
					user_name, 
					user_surname, 
					user_patronymic, 
					user_phone, 
					user_address, 
					user_login, 
					user_password, 
					user_password_salt, 
					user_registration_date, 
					user_is_admin 
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), 0)`,
            [
                req.body.name,
                req.body.surname,
                req.body.patronymic,
                req.body.phone,
                req.body.address,
                req.body.login,
                hashedPassword,
                salt,
            ]
        )
        .then((rows) => {
            res.redirect('/login');
        })
        .catch((e) => {
            if (e.code === 'ER_DUP_ENTRY') {
                res.render('register', {
                    errors: ['Уже есть пользователь с таким логином'],
                    name: req.body.name,
                    surname: req.body.surname,
                    patronymic: req.body.patronymic,
                    phone: req.body.phone,
                    address: req.body.address,
                });
                return;
            }
            res.status(500).end();
        });
});

app.post('/logout', ensureAuthenticated, (req, res) => {
    req.logout();
    res.redirect('/');
});

app.post('/cart/add', (req, res) => {
    if (
        !req.body.id ||
        !req.body.size_id ||
        !req.body.type ||
        !req.body.quantity
    ) {
        res.status(400).end();
        return;
    }
    const item = {
        type: String(req.body.type),
        id: String(req.body.id),
        sizeID: String(req.body.size_id),
        quantity: parseInt(req.body.quantity, 10),
    };
    if (!req.session.cart) {
        req.session.cart = [item];
    } else {
        const found = req.session.cart.find(
            (el) =>
                el.type === item.type &&
                el.sizeID === item.sizeID &&
                el.id === item.id
        );
        if (found) {
            found.quantity += parseInt(req.body.quantity, 10);
        } else {
            req.session.cart.push(item);
        }
    }
    res.locals.cart = req.session.cart;
    res.render('cartAdded');
});

app.get('/cart', (req, res) => {
    const cart = req.session.cart || [];
    if (cart.length === 0) {
        res.render('cartEmpty');
        return;
    }
    const obj = {};
    for (const item of cart) {
        if (!obj[item.id]) {
            obj[item.id] = new Set(item.sizeID);
        } else {
            obj[item.id].add(item.sizeID);
        }
    }
    database
        .query(
            `
		SELECT pizza_size.size_value, pizza_title.pizza_name, pizza.pizza_price, pizza_title.pizza_title_id, pizza_size.pizza_size_id
		FROM pizza 
		INNER JOIN pizza_title ON pizza_title.pizza_title_id = pizza.pizza_title_id
		INNER JOIN pizza_size ON pizza_size.pizza_size_id = pizza.pizza_size_id
		WHERE 
		${Object.keys(obj)
            .map(
                (pizza_title_id) => `
				(
					pizza.pizza_title_id = ${database.escape(pizza_title_id)} 
					AND 
					pizza.pizza_size_id IN 
						( ${Array.from(obj[pizza_title_id])
                            .map((s) => database.escape(s))
                            .join(',')} )
				)
			`
            )
            .join(' OR ')}
	`
        )
        .then((rows) => {
            const pizzasInfo = cart.map((cartItem) => {
                return Object.assign(
                    {
                        quantity: cartItem.quantity,
                    },
                    rows.find(
                        (row) =>
                            row.pizza_title_id == cartItem.id &&
                            row.pizza_size_id == cartItem.sizeID
                    )
                );
            });
            const sum = pizzasInfo.reduce((acum, current) => {
                return (acum += current.pizza_price * current.quantity);
            }, 0);

            res.render('cart', { pizzasInfo, sum });
        });
});

app.post('/cart/delete', (req, res) => {
    const index = req.session.cart.findIndex(
        (el) => el.id == req.body.pizza_id && el.sizeID == req.body.size_id
    );
    if (index != -1) {
        req.session.cart.splice(index, 1);
    }
    res.redirect('/cart');
});

app.post('/cart/order', (req, res) => {
    const userID = req.session.passport ? req.session.passport.user : null;
    database
        .query(
            `INSERT INTO orders
		( 
					user_id, 
					order_address, 
					order_user_phone, 
					order_comment
		) VALUES (?, ?, ?, ?)`,
            [userID, req.body.address, req.body.phone, req.body.comment]
        )
        .then((result) => {
            const order_pizza = req.session.cart.map((pizza) => {
                return [
                    result.insertId,
                    pizza.id,
                    pizza.sizeID,
                    pizza.quantity,
                ];
            });
            database
                .query(
                    `INSERT INTO orders_pizza
			( 
						order_id, 
						pizza_title_id, 
						pizza_size_id, 
						quantity
			) VALUES ?`,
                    [order_pizza]
                )
                .then(() => {
                    req.session.cart = [];
                    res.render('orderSubmited');
                });
        });
});

app.get('/me', (req, res) => {
    res.render('user', {
        name: req.user.user_name,
        surname: req.user.user_surname,
        patronymic: req.user.user_patronymic,
        phone: req.user.user_phone,
        address: req.user.user_address,
    });
});

app.post('/me', (req, res) => {
    const errors = [];

    if (!req.body.name) {
        errors.push('Неверно введено имя');
    }
    if (!req.body.surname) {
        errors.push('Неверно введена фамилия');
    }
    if (!req.body.patronymic) {
        errors.push('Неверно введено отчество');
    }
    if (!req.body.phone) {
        errors.push('Неверно введен номер телефона');
    }
    if (!req.body.address) {
        errors.push('Наверно введен адрес');
    }
    if (errors.length > 0) {
        res.render('user', {
            errors,
            name: req.body.name,
            surname: req.body.surname,
            patronymic: req.body.patronymic,
            phone: req.body.phone,
            address: req.body.address,
        });
        return;
    }
    database
        .query(
            `UPDATE user SET 
                user_name = ?,
                user_surname = ?,
                user_patronymic = ?,
                user_phone = ?,
                user_address = ?
             WHERE user_id = ?`,
            [
                req.body.name,
                req.body.surname,
                req.body.patronymic,
                req.body.phone,
                req.body.address,
                req.session.passport.user,
            ]
        )
        .then((result) => {
            res.render('user', {
                success: true,
                name: req.body.name,
                surname: req.body.surname,
                patronymic: req.body.patronymic,
                phone: req.body.phone,
                address: req.body.address,
            });
        });
});

app.get('/admin', (req, res) => {
    database
        .query(
            `SELECT order_id, order_user_phone, order_address, order_comment, order_date 
		        FROM orders
		     WHERE order_is_done = 0`
        )
        .then((rows) => {
            orders = rows.map((current) => {
                return {
                    id: current.order_id,
                    phone: current.order_user_phone,
                    address: current.order_address,
                    comment: current.order_comment,
                    date: current.order_date,
                };
            });
            database
                .query(
                    `SELECT 
                        orders_pizza.order_id,
                        pizza_title.pizza_name,
                        pizza.pizza_price,
                        pizza_size.size_value,
                        orders_pizza.quantity
                    FROM orders_pizza 
                        INNER JOIN pizza ON orders_pizza.pizza_title_id = pizza.pizza_title_id AND orders_pizza.pizza_size_id = pizza.pizza_size_id
                        INNER JOIN pizza_size ON pizza_size.pizza_size_id = pizza.pizza_size_id
                        INNER JOIN pizza_title ON pizza_title.pizza_title_id = pizza.pizza_title_id
                    WHERE orders_pizza.order_id IN (${orders
                        .map((order) => database.escape(order.id))
                        .join(', ')})`
                )
                .then((rows2) => {
                    pizzas = rows2.map((row) => {
                        return {
                            orderID: row.order_id,
                            name: row.pizza_name,
                            price: row.pizza_price,
                            size: row.size_value,
                            quantity: row.quantity,
                        };
                    });
                    orders = orders.map((order) => {
                        order.pizzas = pizzas.filter(
                            (pizza) => order.id == pizza.orderID
                        );
                        order.sum = order.pizzas.reduce(
                            (acum, pizza) =>
                                (acum += pizza.quantity * pizza.price),
                            0
                        );
                        return order;
                    });
                    res.render('admin', orders);
                });
        });
});

app.post('/admin', (req, res) => {
    orderID = req.body.orderID;
    database.query(
        `
		UPDATE orders SET 
			order_is_done = 1, 
			order_delivery_date = NOW() 
		WHERE order_id = ?
	`,
        orderID
    );
    res.redirect('/admin');
});

app.use((req, res, next) => {
    res.status(404).end();
});

app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).end();
});

app.listen(3000, () => console.log('Listening on port 3000'));
