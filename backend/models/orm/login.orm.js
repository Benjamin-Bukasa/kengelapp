// backend/models/orm/login.orm.js
const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');
const Utilisateurs = require('./utilisateurs.orm');
const Generique = require('./generique.orm');
const Entite = require('./entite.orm');



const Login = sequelize.define('Login', {
  IdLogin: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true, field: 'IdLogin' },
  IdUserFk: { type: DataTypes.INTEGER, allowNull: false, field: 'IdUserFk' },
  IdTypeLoginFk: { type: DataTypes.INTEGER, allowNull: false, field: 'IdTypeLoginFk' },
  DateLogin: { type: DataTypes.DATE, defaultValue: DataTypes.NOW, field: 'DateLogin' },
  IdEntiteFk: { type: DataTypes.INTEGER, allowNull: true, field: 'IdEntiteFk' }
}, {
  tableName: 'T_Login',
  timestamps: false,
  freezeTableName: true,
});

// Associations
Login.belongsTo(Entite, {foreignKey: 'IdEntiteFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});
Login.belongsTo(Generique, {foreignKey: 'IdTypeLoginFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});
Login.belongsTo(Utilisateurs, {foreignKey: 'IdUserFk',onUpdate: 'CASCADE',onDelete: 'SET NULL'});

module.exports = Login;
