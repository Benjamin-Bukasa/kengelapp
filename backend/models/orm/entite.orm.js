// backend/models/orm/entite.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Generique = require('./generique.orm');

const Entite = sequelize.define('Entite', {
  IdEntite: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,field: 'IdEntite'},
  NomEntite: {type: DataTypes.TEXT,allowNull: false,field: 'NomEntite'},
  PhoneEntite: {type: DataTypes.TEXT,allowNull: true,unique: true,field: 'PhoneEntite'},
  EmailEntite: {type: DataTypes.STRING(255),allowNull: false,unique: true,field: 'EmailEntite'},
  AdresseEntite: {type: DataTypes.TEXT,allowNull: true,field: 'AdresseEntite' },
  DateCreationEntite: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,field: 'DateCreationEntite'},
  IdTypeEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdTypeEntiteFk'},
  ValideEntite: {type: DataTypes.BOOLEAN,defaultValue: true,field: 'ValideEntite'}
}, 
{
  tableName: 'T_Entite',
  timestamps: false
});

// Associations
Generique.belongsTo(CategorieGenerique, {foreignKey: 'IdCategorieGeneriqueFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});


module.exports = Entite;
