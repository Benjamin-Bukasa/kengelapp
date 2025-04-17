const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VEnseignant = sequelize.define('VEnseignant', {
  IdEnseignant: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdEnseignant' },
  CodeEnseignant: { type: DataTypes.STRING, field: 'CodeEnseignant' },
  IdSpecialiteEnseignantFk: { type: DataTypes.INTEGER, field: 'IdSpecialiteEnseignantFk' },
  specialite: { type: DataTypes.STRING, field: 'specialite' },
  salaire_enseignant: { type: DataTypes.STRING, field: 'salaire_enseignant' },
  IdDeviseFk: { type: DataTypes.INTEGER, field: 'IdDeviseFk' },
  nom_devise: { type: DataTypes.STRING, field: 'nom_devise' },
  DateEmbaucheEnseignant: { type: DataTypes.DATEONLY, field: 'DateEmbaucheEnseignant' },
  ValideEnseignant: { type: DataTypes.BOOLEAN, field: 'ValideEnseignant' },
  nom_enseignant: { type: DataTypes.STRING, field: 'nom_enseignant' },
  prenom_enseignant: { type: DataTypes.STRING, field: 'prenom_enseignant' },
  EmailUser: { type: DataTypes.STRING, field: 'EmailUser' },
  PhoneUser: { type: DataTypes.STRING, field: 'PhoneUser' },
  IdRoleFk: { type: DataTypes.INTEGER, field: 'IdRoleFk' },
  roles: { type: DataTypes.STRING, field: 'roles' },
  ValideUser: { type: DataTypes.BOOLEAN, field: 'ValideUser' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Enseignant',
  timestamps: false,
  freezeTableName: true
});

module.exports = VEnseignant;
