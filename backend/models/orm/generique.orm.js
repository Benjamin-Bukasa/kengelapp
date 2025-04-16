// backend/models/orm/generique.orm.js
const { DataTypes } = require('sequelize');
const sequelize  = require('../../config/sequelize');
const CategorieGenerique = require('./categorieGenerique.orm');

const Generique = sequelize.define('Generique', {
  IdGenerique: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdGenerique'},
  NomGenerique: {type: DataTypes.STRING(25),allowNull: false,field: 'NomGenerique'},
  CodeGenerique: {type: DataTypes.STRING(25),allowNull: false,field: 'CodeGenerique'},
  ObsGenerique: {type: DataTypes.STRING,allowNull: true,field: 'ObsGenerique'},
  ValideGenerique: {type: DataTypes.BOOLEAN,defaultValue: true,field: 'ValideGenerique'},
  IdCategorieGeneriqueFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdCategorieGeneriqueFk' }
}, 
{
  tableName: 'T_Generique',
  timestamps: false
});
// Associations
CategorieGenerique.belongsTo(Entite, {foreignKey: 'IdEntiteFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});

module.exports = Generique;
