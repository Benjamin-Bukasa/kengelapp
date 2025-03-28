const { Client } = require('pg');
const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'PostgreSQL2025', 
    database: 'KengelApp'
});

client.connect()
    .then(() => console.log('Connexion réussie à PostgreSQL'))
    .catch(err => console.error('Erreur de connexion à PostgreSQL', err));
