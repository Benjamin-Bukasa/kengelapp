const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VUtilisateur = sequelize.define('VUtilisateur', {
  DatecreationUser: { type: DataTypes.DATE, field: 'DatecreationUser' },
  IdUser: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdUser' },
  IdRoleFk: { type: DataTypes.INTEGER, field: 'IdRoleFk' },
  roles: { type: DataTypes.STRING, field: 'roles' },
  noms: { type: DataTypes.STRING, field: 'noms' },
  email: { type: DataTypes.STRING, field: 'email' },
  mot_de_passe: { type: DataTypes.STRING, field: 'mot_de_passe' },
  phone: { type: DataTypes.STRING, field: 'phone' },
  valide: { type: DataTypes.BOOLEAN, field: 'valide' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Utilisateur',
  timestamps: false,
  freezeTableName: true
});

module.exports = VUtilisateur;
