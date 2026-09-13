import type { Meta, StoryObj } from "@storybook/react-vite"
import { InfoIcon } from "lucide-react"

import { Button } from "studio-ui/components/button"
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "studio-ui/components/tooltip"

const meta = {
  title: "UI/Tooltip",
  component: Tooltip,
} satisfies Meta<typeof Tooltip>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => (
    <Tooltip>
      <TooltipTrigger asChild>
        <Button variant="outline" size="icon" aria-label="More information">
          <InfoIcon />
        </Button>
      </TooltipTrigger>
      <TooltipContent>Build configuration details</TooltipContent>
    </Tooltip>
  ),
}
