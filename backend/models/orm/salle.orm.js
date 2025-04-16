// backend/models/orm/salle.orm.js

const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');

const Salle = sequelize.define('Salle', {
  IdSalle: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,allowNull: false,field: 'IdSalle'},
  NomSalle: {type: DataTypes.STRING(25),allowNull: false,field: 'NomSalle'},
  CapaciteSalle: {type: DataTypes.DECIMAL,allowNull: false,field: 'CapaciteSalle'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'}
}, 
{
  tableName: 'T_Salle',
  timestamps: false
});

// Associations
Salle.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Salle;
