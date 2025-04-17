const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VLogin = sequelize.define('VLogin', {
  DateLogin: { type: DataTypes.DATE, field: 'DateLogin' },
  IdLogin: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdLogin' },
  IdUserFk: { type: DataTypes.INTEGER, field: 'IdUserFk' },
  noms: { type: DataTypes.STRING, field: 'noms' },
  IdRoleFk: { type: DataTypes.INTEGER, field: 'IdRoleFk' },
  roles: { type: DataTypes.STRING, field: 'roles' },
  IdTypeLoginFk: { type: DataTypes.INTEGER, field: 'IdTypeLoginFk' },
  type_login: { type: DataTypes.STRING, field: 'type_login' },
  EmailUser: { type: DataTypes.STRING, field: 'EmailUser' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Login',
  timestamps: false,
  freezeTableName: true
});

module.exports = VLogin;
