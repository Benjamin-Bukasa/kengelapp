const { DataTypes } = require('sequelize');
const sequelize = require('../../config/sequelize');

const VPaiement = sequelize.define('VPaiement', {
  IdPaiement: { type: DataTypes.INTEGER, primaryKey: true, field: 'IdPaiement' },
  DatePaiement: { type: DataTypes.DATE, field: 'DatePaiement' },
  CodePaiement: { type: DataTypes.STRING, field: 'CodePaiement' },
  IdUserFk: { type: DataTypes.INTEGER, field: 'IdUserFk' },
  utilisateur: { type: DataTypes.STRING, field: 'utilisateur' },
  IdPayeurFk: { type: DataTypes.INTEGER, field: 'IdPayeurFk' },
  payeur: { type: DataTypes.STRING, field: 'payeur' },
  IdTypePaiementFk: { type: DataTypes.INTEGER, field: 'IdTypePaiementFk' },
  type_paiement: { type: DataTypes.STRING, field: 'type_paiement' },
  IdDeviseFk: { type: DataTypes.INTEGER, field: 'IdDeviseFk' },
  montant: { type: DataTypes.STRING, field: 'montant' },
  IdStatutPaiementFk: { type: DataTypes.INTEGER, field: 'IdStatutPaiementFk' },
  statut: { type: DataTypes.STRING, field: 'statut' },
  IdTypeMouvementFk: { type: DataTypes.INTEGER, field: 'IdTypeMouvementFk' },
  type_mouvement: { type: DataTypes.STRING, field: 'type_mouvement' },
  ObsPaiement: { type: DataTypes.STRING, field: 'ObsPaiement' },
  IdEntiteFk: { type: DataTypes.INTEGER, field: 'IdEntiteFk' },
  NomEntite: { type: DataTypes.STRING, field: 'NomEntite' },
  id_type_entite: { type: DataTypes.INTEGER, field: 'id_type_entite' },
  type_entite: { type: DataTypes.STRING, field: 'type_entite' }
}, {
  tableName: 'V_Paiement',
  timestamps: false,
  freezeTableName: true
});

module.exports = VPaiement;
