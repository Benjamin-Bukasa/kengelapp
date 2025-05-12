"use client"

import * as React from "react"
import { TrendingUp } from "lucide-react"

import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "../ui/card"

import {
  ChartContainer,
  BasicPieChart,
} from "../ui/chart"

// ✅ Données adaptées au format attendu par BasicPieChart
const chartData = [
  { label: "Chrome", value: 275 },
  { label: "Firefox", value: 200 },
  { label: "Edge", value: 140 },
  { label: "Safari", value: 180 },
]

// 🎨 Couleurs personnalisées : bleu vif + pâle, orange vif + pâle
const chartColors = ["#3b82f6", "#f97316", "#bfdbfe", "#fdba74"]

export function DonutChart() {
  const totalVisitors = React.useMemo(() => {
    return chartData.reduce((acc, curr) => acc + curr.value, 0)
  }, [])

  return (
    <Card className="flex flex-col h-full">
      <CardHeader className="items-center pb-0">
        <CardTitle>Répartitions</CardTitle>
        <CardDescription>Janvier - Juin 2024</CardDescription>
      </CardHeader>

      <CardContent className="flex-1 pb-0">
        <ChartContainer className="mx-auto max-w-sm">
          <BasicPieChart data={chartData} colors={chartColors} />
        </ChartContainer>
      </CardContent>

      <CardFooter className="flex-col gap-2 text-sm">
        <div className="flex items-center gap-2 font-medium leading-none">
          Hausse de 5.2% ce mois-ci <TrendingUp className="h-4 w-4" />
        </div>
        <div className="leading-none text-muted-foreground">
          Total visiteurs : <strong>{totalVisitors.toLocaleString()}</strong>
        </div>
      </CardFooter>
    </Card>
  )
}
