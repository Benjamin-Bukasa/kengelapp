// backend/utils/getPrismaViews.js
const prisma = require('../config/db');

async function getPrismaViews() {
  const result = await prisma.$queryRaw`
    SELECT table_name
    FROM information_schema.views
    WHERE table_schema = 'public' AND (
      table_name LIKE 'V\\_%' OR table_name LIKE 'VS\\_%'
    )
  `;
  return result.map(v => v.table_name);
}

module.exports = getPrismaViews;
