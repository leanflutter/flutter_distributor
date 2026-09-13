import type { Meta, StoryObj } from "@storybook/react-vite"
import { ChevronsUpDownIcon } from "lucide-react"

import { Button } from "studio-ui/components/button"
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "studio-ui/components/collapsible"
import { Separator } from "studio-ui/components/separator"

const meta = {
  title: "UI/Collapsible",
  component: Collapsible,
} satisfies Meta<typeof Collapsible>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => (
    <Collapsible className="flex w-80 flex-col gap-2">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium">3 deployment targets</span>
        <CollapsibleTrigger asChild>
          <Button variant="ghost" size="icon-sm" aria-label="Toggle targets">
            <ChevronsUpDownIcon />
          </Button>
        </CollapsibleTrigger>
      </div>
      <div className="rounded-lg border px-3 py-2 text-sm">macOS</div>
      <CollapsibleContent className="flex flex-col gap-2">
        <div className="rounded-lg border px-3 py-2 text-sm">Windows</div>
        <div className="rounded-lg border px-3 py-2 text-sm">Linux</div>
      </CollapsibleContent>
      <Separator />
    </Collapsible>
  ),
}
