// backend/models/orm/apprenant.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');

const Apprenant = sequelize.define('Apprenant', {
  IdApprenant: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, field: 'IdApprenant' },
  NomApprenant: { type: DataTypes.STRING, allowNull: false, field: 'NomApprenant' },
  IdEntiteFk: { type: DataTypes.INTEGER, allowNull: false, field: 'IdEntiteFk' },
}, {
  tableName: 'T_Apprenant',
  timestamps: false
});

// Associations
Apprenant.belongsTo(Entite, { foreignKey: 'IdEntiteFk' });

module.exports = Apprenant;
