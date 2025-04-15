import React from "react"
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
} from "recharts"

// 🎛️ Config par défaut exportable
export const ChartConfig = {
  xKey: "name",
  bars: [
    { key: "mobile", color: "#38bdf8" },
    { key: "desktop", color: "#4f46e5" },
  ],
}

// 💡 Conteneur stylisé
export const ChartContainer = ({ children, className = "" }) => {
  return (
    <div className={`w-full rounded-lg bg-white p-4 shadow-sm ${className}`}>
      {children}
    </div>
  )
}
ChartContainer.displayName = "ChartContainer"

// 📊 Bar Chart générique
export const BasicBarChart = ({ data, xKey = "name", bars = [] }) => (
  <ResponsiveContainer width="100%" height={300}>
    <BarChart data={data}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey={xKey} />
      <YAxis />
      <Tooltip />
      {bars.map((bar, index) => (
        <Bar key={index} dataKey={bar.key} fill={bar.color || "#0076F2"} />
      ))}
    </BarChart>
  </ResponsiveContainer>
)
BasicBarChart.displayName = "BasicBarChart"

// 📈 Line Chart générique
export const BasicLineChart = ({ data, xKey = "name", lines = [] }) => (
  <ResponsiveContainer width="100%" height={300}>
    <LineChart data={data}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey={xKey} />
      <YAxis />
      <Tooltip />
      {lines.map((line, index) => (
        <Line
          key={index}
          type="monotone"
          dataKey={line.key}
          stroke={line.color || "#0076F2"}
          strokeWidth={2}
        />
      ))}
    </LineChart>
  </ResponsiveContainer>
)
BasicLineChart.displayName = "BasicLineChart"

// 🥧 Pie Chart générique
export const BasicPieChart = ({ data, colors = [] }) => (
  <ResponsiveContainer width="100%" height={300}>
    <PieChart>
      <Pie
        data={data}
        dataKey="value"
        nameKey="label"
        outerRadius={100}
        fill="#8884d8"
        label
      >
        {data.map((entry, index) => (
          <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
        ))}
      </Pie>
      <Tooltip />
    </PieChart>
  </ResponsiveContainer>
)
BasicPieChart.displayName = "BasicPieChart"

// Tooltip container stylisé
export const ChartTooltip = ({ children }) => (
  <div className="bg-black text-white text-xs p-2 rounded shadow">
    {children}
  </div>
)
ChartTooltip.displayName = "ChartTooltip"

// Contenu du tooltip
export const ChartTooltipContent = ({ label, value }) => (
  <div>
    <div className="font-semibold">{label}</div>
    <div>{value}</div>
  </div>
)
ChartTooltipContent.displayName = "ChartTooltipContent"
