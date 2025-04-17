const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VEnseignantSalaire = sequelize.define('VEnseignantSalaire', {
  IdEnseignant: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdEnseignant' },
  CodeEnseignant: { type: DataTypes.STRING, field: 'CodeEnseignant' },
  IdUserFk: { type: DataTypes.INTEGER, field: 'IdUserFk' },
  nom_enseignant: { type: DataTypes.STRING, field: 'nom_enseignant' },
  IdSpecialiteEnseignantFk: { type: DataTypes.INTEGER, field: 'IdSpecialiteEnseignantFk' },
  NomGenerique: { type: DataTypes.STRING, field: 'NomGenerique' },
  salaire: { type: DataTypes.STRING, field: 'salaire' },
  IdDeviseFk: { type: DataTypes.INTEGER, field: 'IdDeviseFk' },
  DateEmbaucheEnseignant: { type: DataTypes.DATEONLY, field: 'DateEmbaucheEnseignant' },
  ValideEnseignant: { type: DataTypes.BOOLEAN, field: 'ValideEnseignant' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_EnseignantSalaire',
  timestamps: false,
  freezeTableName: true
});

module.exports = VEnseignantSalaire;
