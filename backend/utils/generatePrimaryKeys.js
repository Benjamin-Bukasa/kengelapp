//backend/utils/generatePrimaryKeys.js
// Ce script génère un fichier utils/primaryKeys.js contenant les clés primaires de chaque modèle Prisma
// backend/utils/generatePrimaryKeys.js

const fs = require('fs');
const path = require('path');

const schemaPath = path.join(__dirname, '../prisma/schema.prisma');
const outputPath = path.join(__dirname, 'primaryKeys.cache.js');

const schema = fs.readFileSync(schemaPath, 'utf-8');
const lines = schema.split('\n');

const primaryKeys = {};
let currentModel = null;
let insideModel = false;

for (let i = 0; i < lines.length; i++) {
  let line = lines[i].trim();

  // Début d’un modèle
  if (line.startsWith('model ')) {
    currentModel = line.split(' ')[1];
    insideModel = true;
    continue;
  }

  // Fin du modèle
  if (insideModel && line === '}') {
    insideModel = false;
    currentModel = null;
    continue;
  }

  if (!insideModel || !currentModel) continue;

  // Clé primaire simple (@id)
  if (line.includes('@id') && !line.includes('@@')) {
    const field = line.split(/\s+/)[0];
    primaryKeys[currentModel] = field;
    continue;
  }

  // Clé primaire composée (@@id)
  if (line.startsWith('@@id')) {
    const match = line.match(/@@id\s*\(\[(.+?)\]\)/);
    if (match) {
      const fields = match[1].split(',').map(f => f.trim());
      primaryKeys[currentModel] = fields;
    }
  }
}

const output = 'module.exports = ' + JSON.stringify(primaryKeys, null, 2) + ';\n';
fs.writeFileSync(outputPath, output);

console.log('✅ Fichier généré : primaryKeys.cache.js');
