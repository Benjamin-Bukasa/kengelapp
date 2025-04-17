// backend/models/orm/categorieGenerique.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const CategorieGenerique = sequelize.define('CategorieGenerique', {
  IdCategorieGenerique: {type: DataTypes.INTEGER, primaryKey: true,autoIncrement: true,field: 'IdCategorieGenerique'},
  NomCategorieGenerique: {type: DataTypes.STRING(25),allowNull: false,field: 'NomCategorieGenerique'},
  ModuleCategorieGenerique: {type: DataTypes.STRING(100),field: 'ModuleCategorieGenerique'},
  ValideCategorieGenerique: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValideCategorieGenerique'},
}, 
{
  tableName: 'T_CategorieGenerique',
  timestamps: false,
  freezeTableName: true,
});

module.exports = CategorieGenerique;
