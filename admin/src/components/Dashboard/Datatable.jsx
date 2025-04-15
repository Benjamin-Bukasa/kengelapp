import React from "react"
import { institutions } from "../../data/institution"
import {
  // ColumnDef,
  flexRender,
  getCoreRowModel,
  useReactTable,
} from "@tanstack/react-table"

export const columns = [
  {
    accessorKey: "institution",
    header: "Institution",
  },
  {
    accessorKey: "prefet",
    header: "Préfet",
  },
  {
    accessorKey: "promoteur",
    header: "Promoteur",
  },
  {
    accessorKey: "adresse",
    header: "Adresse",
  },
  {
    accessorKey: "effectifEleves",
    header: "Élèves",
  },
  {
    accessorKey: "effectifClasses",
    header: "Classes",
  },
  {
    accessorKey: "effectifProfesseurs",
    header: "Professeurs",
  },
  {
    accessorKey: "effectifSalles",
    header: "Salles",
  },
  {
    accessorKey: "validiteAbonnement",
    header: "Valide",
    cell: ({ row }) => (
      <span>{row.getValue("validiteAbonnement") ? "✅" : "❌"}</span>
    ),
  },
  {
    accessorKey: "typeAbonnement",
    header: "Type",
    cell: ({ row }) => (
      <span className="capitalize">{row.getValue("typeAbonnement")}</span>
    ),
  },
  {
    accessorKey: "dateAbonnement",
    header: "Date",
  },
]

export default function Datatable() {
  const table = useReactTable({
    data: institutions,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <div className="rounded-md border p-4">
      <h2 className="text-lg font-semibold mb-4">Liste des institutions</h2>
      <table className="w-full text-sm text-left">
        <thead className="bg-gray-100">
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map(header => (
                <th key={header.id} className="p-2 border">
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id} className="p-2 border">
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
