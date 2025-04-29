//backend/app.js
const express = require('express');
const app = express();
const routes = require('./routes/index.routes');
const errorHandler = require('./middlewares/errorHandler');

app.use(express.json());
app.use('/api', routes);


// Gestion des erreurs globales
app.use(errorHandler);

module.exports = app;
