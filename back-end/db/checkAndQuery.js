const { Client } = require('pg');

// Configuration de la connexion
const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'PostgreSQL2025',
    database: 'KengelApp'
});
// Fonction pour vérifier la connexion
async function checkConnection() {
    try {
        await client.connect();
        console.log('Connexion réussie à PostgreSQL');
    } catch (err) {
        console.error('Erreur de connexion à PostgreSQL :', err);
        process.exit(1); // Quitte le processus en cas d'échec
    }
}

// Fonction pour sélectionner les données de la table T_Caisse
async function selectFromTable() {
    const query = 'SELECT * FROM public."T_Caisse"'; // Inclure le schéma et utiliser des guillemets doubles
    try {
        console.log('Exécution de la requête :', query); // Log de la requête
        const result = await client.query(query);
        if (result.rows.length === 0) {
            console.log('Aucune donnée trouvée dans la table T_Caisse.');
        } else {
            console.log('Données récupérées :', result.rows); // Log des lignes récupérées
        }
    } catch (err) {
        console.error('Erreur lors de la récupération des données :', err);
    } finally {
        await client.end(); // Ferme la connexion après la requête
    }
}

// Exécution des fonctions
(async () => {
    await checkConnection();
    await selectFromTable();
})();
