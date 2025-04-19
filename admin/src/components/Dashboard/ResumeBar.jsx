"use client"

import { TrendingUp } from "lucide-react"
import {
  BarChart,
  Bar,
  XAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts"

import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "../../components/ui/card.jsx"

import {
  ChartContainer,
  ChartTooltip,
} from "../../components/ui/chart"

const chartData = [
  { month: "January", desktop: 186, mobile: 80 },
  { month: "February", desktop: 305, mobile: 200 },
  { month: "March", desktop: 237, mobile: 120 },
  { month: "April", desktop: 73, mobile: 190 },
  { month: "May", desktop: 209, mobile: 130 },
  { month: "June", desktop: 214, mobile: 140 },
]

const chartConfig = {
  desktop: {
    label: "Abonnés simples",
    color: "#3b82f6",
  },
  mobile: {
    label: "Abonnés premium",
    color: "orange",
  },
}

export function ResumeBar() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Statistique des abonnements</CardTitle>
        <CardDescription>Janvier - Juin 2025</CardDescription>
      </CardHeader>

      <CardContent>
        <ChartContainer>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData}>
              <CartesianGrid vertical={false} strokeDasharray="3 3" />
              <XAxis
                dataKey="month"
                tickLine={false}
                tickMargin={10}
                axisLine={false}
                tickFormatter={(value) => value.slice(0, 3)}
              />
              <Tooltip
                cursor={false}
                content={({ label, payload }) => (
                  <div className="bg-black text-white text-xs p-2 rounded shadow">
                    <div className="font-semibold mb-1">{label}</div>
                    {payload?.map((entry, index) => (
                      <div key={index} className="flex justify-between gap-4">
                        <span>{chartConfig[entry.dataKey]?.label}:</span>
                        <span>{entry.value}</span>
                      </div>
                    ))}
                  </div>
                )}
              />
              <Bar
                dataKey="desktop"
                fill={chartConfig.desktop.color}
                radius={[4, 4, 0, 0]}
              />
              <Bar
                dataKey="mobile"
                fill={chartConfig.mobile.color}
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>

          {/* Légende dynamique */}
          <div className="mt-4 flex gap-6">
            {Object.entries(chartConfig).map(([key, { label, color }]) => (
              <div key={key} className="flex items-center gap-2 text-sm">
                <span
                  className="inline-block w-3 h-3 rounded-full"
                  style={{ backgroundColor: color }}
                />
                <span className="text-muted-foreground">{label}</span>
              </div>
            ))}
          </div>
        </ChartContainer>
      </CardContent>

      <CardFooter className="flex-col items-start gap-2 text-sm">
        <div className="flex gap-2 font-medium leading-none">
          Taux de croissance de 5.2% ce mois-ci <TrendingUp className="h-4 w-4" />
        </div>
        <div className="leading-none text-muted-foreground">
          Nombre total d’abonnés sur les 6 derniers mois
        </div>
      </CardFooter>
    </Card>
  )
}
