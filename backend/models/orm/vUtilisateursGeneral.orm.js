const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VUtilisateursGeneral = sequelize.define('VUtilisateursGeneral', {
  IdUser: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdUser' },
  IdRoleFk: { type: DataTypes.INTEGER, field: 'IdRoleFk' },
  roles: { type: DataTypes.STRING, field: 'roles' },
  noms: { type: DataTypes.STRING, field: 'noms' },
  EmailUser: { type: DataTypes.STRING, field: 'EmailUser' },
  MotdepasseUser: { type: DataTypes.STRING, field: 'MotdepasseUser' },
  PhoneUser: { type: DataTypes.STRING, field: 'PhoneUser' },
  DatecreationUser: { type: DataTypes.DATE, field: 'DatecreationUser' },
  ValideUser: { type: DataTypes.BOOLEAN, field: 'ValideUser' },
  idpersonne: { type: DataTypes.INTEGER, field: 'idpersonne' },
  codepersonne: { type: DataTypes.STRING, field: 'codepersonne' },
  typeutilisateur: { type: DataTypes.STRING, field: 'typeutilisateur' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_UtilisateursGeneral',
  timestamps: false,
  freezeTableName: true
});

module.exports = VUtilisateursGeneral;
