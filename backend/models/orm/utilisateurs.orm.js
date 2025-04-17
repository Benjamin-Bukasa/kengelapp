// backend/models/orm/utilisateurs.orm.js

const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Entite = require('./entite.orm');
const Generique = require('./generique.orm');

const Utilisateurs = sequelize.define('Utilisateurs', {
  IdUser: {type: DataTypes.INTEGER,primaryKey: true,autoIncrement: true,allowNull: false,field: 'IdUser'},
  NomUser: {type: DataTypes.STRING(100),allowNull: false,field: 'NomUser'},
  PrenomUser: {type: DataTypes.STRING(100),allowNull: false,field: 'PrenomUser'},
  EmailUser: {type: DataTypes.STRING(150),allowNull: false,unique: true,  validate: {isEmail: true},field: 'EmailUser'},
  MotdepasseUser: {type: DataTypes.TEXT,allowNull: false,field: 'MotdepasseUser'},
  PhoneUser: {type: DataTypes.STRING(20),allowNull: true,  validate: {is: /^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[0-9\- \(\)]{5,20}$/i },field: 'PhoneUser'},
  DatecreationUser: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,field: 'DatecreationUser'},
  IdRoleFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdRoleFk'},
  ValideUser: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: true,field: 'ValideUser'},
  SexeUser: {type: DataTypes.CHAR(1),allowNull: false,validate: {  isIn: [['M', 'F']]},field: 'SexeUser'},
  DateModificationUser: {type: DataTypes.DATE,defaultValue: DataTypes.NOW,allowNull: false,field: 'DateModificationUser'},
  UrlPhoto: {type: DataTypes.TEXT,allowNull: true,field: 'UrlPhoto'},
  IdEntiteFk: {type: DataTypes.INTEGER,allowNull: true,field: 'IdEntiteFk'},
  Is_staff: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: false,field: 'Is_staff'},
  Is_Admin: {type: DataTypes.BOOLEAN,allowNull: false,defaultValue: false,field: 'Is_Admin'}
}, 
{
  tableName: 'T_Utilisateurs',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Utilisateurs.belongsTo(Entite, { foreignKey: 'IdEntiteFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });
Utilisateurs.belongsTo(Generique, { foreignKey: 'IdRoleFk', onUpdate: 'CASCADE', onDelete: 'SET NULL' });

module.exports = Utilisateurs;
