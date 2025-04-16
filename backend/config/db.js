// backend/config/db.js  : Connexion à PostgreSQL avec 'pg'

const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'KengelApp',
  password: 'PostgreSQL2025',
  port: 5432,
});
pool.connect()
  .then(() => console.log("Connexion à PostgreSQL réussie"))
  .catch((err) => console.error("Erreur de connexion à PostgreSQL :", err));

module.exports = pool;
