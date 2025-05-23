// Tremor Raw chartColors [v0.1.0]

export const chartColors = {
    blue: {
      bg: "bg-blue-500",
      stroke: "stroke-blue-500",
      fill: "fill-blue-500",
      text: "text-blue-500",
    },
    emerald: {
      bg: "bg-emerald-500",
      stroke: "stroke-emerald-500",
      fill: "fill-emerald-500",
      text: "text-emerald-500",
    },
    violet: {
      bg: "bg-violet-500",
      stroke: "stroke-violet-500",
      fill: "fill-violet-500",
      text: "text-violet-500",
    },
    amber: {
      bg: "bg-amber-500",
      stroke: "stroke-amber-500",
      fill: "fill-amber-500",
      text: "text-amber-500",
    },
    gray: {
      bg: "bg-gray-500",
      stroke: "stroke-gray-500",
      fill: "fill-gray-500",
      text: "text-gray-500",
    },
    cyan: {
      bg: "bg-cyan-500",
      stroke: "stroke-cyan-500",
      fill: "fill-cyan-500",
      text: "text-cyan-500",
    },
    pink: {
      bg: "bg-pink-500",
      stroke: "stroke-pink-500",
      fill: "fill-pink-500",
      text: "text-pink-500",
    },
    lime: {
      bg: "bg-lime-500",
      stroke: "stroke-lime-500",
      fill: "fill-lime-500",
      text: "text-lime-500",
    },
    fuchsia: {
      bg: "bg-fuchsia-500",
      stroke: "stroke-fuchsia-500",
      fill: "fill-fuchsia-500",
      text: "text-fuchsia-500",
    },
  };
  
  // Liste des clés disponibles dans chartColors
  export const AvailableChartColors = Object.keys(chartColors);
  
  // Génère une map des catégories avec des couleurs cycliques
  export const constructCategoryColors = (categories, colors) => {
    const categoryColors = new Map();
    categories.forEach((category, index) => {
      categoryColors.set(category, colors[index % colors.length]);
    });
    return categoryColors;
  };
  
  // Renvoie la classe utilitaire associée à une couleur + type
  export const getColorClassName = (color, type) => {
    const fallbackColor = {
      bg: "bg-gray-500",
      stroke: "stroke-gray-500",
      fill: "fill-gray-500",
      text: "text-gray-500",
    };
    return chartColors[color]?.[type] ?? fallbackColor[type];
  };
  
  // Détermine la plage de l’axe Y en fonction des options
  export const getYAxisDomain = (autoMinValue, minValue, maxValue) => {
    const minDomain = autoMinValue ? "auto" : (minValue ?? 0);
    const maxDomain = maxValue ?? "auto";
    return [minDomain, maxDomain];
  };
  
  // Vérifie si tous les objets ont une seule valeur unique pour une clé donnée
  export function hasOnlyOneValueForKey(array, keyToCheck) {
    const val = [];
  
    for (const obj of array) {
      if (Object.prototype.hasOwnProperty.call(obj, keyToCheck)) {
        val.push(obj[keyToCheck]);
        if (val.length > 1) {
          return false;
        }
      }
    }
  
    return true;
  }
  