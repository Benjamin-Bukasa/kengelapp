// backend/models/orm/caisse.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');

const Caisse = sequelize.define('Caisse', {
  IdCaisse: {type: DataTypes.INTEGER, primaryKey: true,autoIncrement: true,field: 'IdCaisse' },
  IdDeviseFk: {type: DataTypes.INTEGER,allowNull: false, unique: true, field: 'IdDeviseFk' },
  MontantCaisse: {type: DataTypes.DECIMAL(10, 2),defaultValue: 0,field: 'MontantCaisse'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Caisse',
  timestamps: false,
  freezeTableName: true,
});
// Associations
Caisse.belongsTo(Generique, { foreignKey: 'IdDeviseFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Caisse.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Caisse;
