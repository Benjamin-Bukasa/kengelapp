import React from "react"
import { cn } from "../../lib/utils"

const Card = React.forwardRef(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("rounded-lg border bg-white text-black shadow-sm", className)}
    {...props}
  />
))
Card.displayName = "Card"

const CardHeader = ({ className, ...props }) => (
  <div className={cn("p-4 border-b", className)} {...props} />
)
CardHeader.displayName = "CardHeader"

const CardTitle = ({ className, ...props }) => (
  <h3 className={cn("text-lg font-semibold", className)} {...props} />
)
CardTitle.displayName = "CardTitle"

const CardDescription = ({ className, ...props }) => (
  <p className={cn("text-sm text-muted-foreground", className)} {...props} />
)
CardDescription.displayName = "CardDescription"

const CardContent = ({ className, ...props }) => (
  <div className={cn("p-4", className)} {...props} />
)
CardContent.displayName = "CardContent"

const CardFooter = ({ className, ...props }) => (
  <div className={cn("p-4 border-t", className)} {...props} />
)
CardFooter.displayName = "CardFooter"

export {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
  CardFooter,
}
