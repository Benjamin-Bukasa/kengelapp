//backend/utils/getPrismaModels.js
// pour récupérer dynamiquement les modèles Prisma à partir du fichier schema.prisma
const fs = require('fs');
const path = require('path');

function getPrismaModels() {
  const schemaPath = path.join(__dirname, '../prisma/schema.prisma');

  if (!fs.existsSync(schemaPath)) {
    throw new Error(`Fichier schema.prisma introuvable à ${schemaPath}`);
  }

  const schema = fs.readFileSync(schemaPath, 'utf-8');
  const modelRegex = /^model\s+(\w+)\s+{/gm;

  const models = [];
  let match;
  while ((match = modelRegex.exec(schema)) !== null) {
    // Prisma accède aux modèles en camelCase : exemple T_Apprenant → t_Apprenant
    const modelName = match[1];
    const formatted = modelName.charAt(0).toLowerCase() + modelName.slice(1);
    models.push(formatted);
  }

  return models;
}

module.exports = getPrismaModels;

