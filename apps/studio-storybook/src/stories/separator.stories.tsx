import type { Meta, StoryObj } from "@storybook/react-vite"

import { Separator } from "studio-ui/components/separator"

const meta = {
  title: "UI/Separator",
  component: Separator,
} satisfies Meta<typeof Separator>

export default meta
type Story = StoryObj<typeof meta>

export const Horizontal: Story = {
  render: () => (
    <div className="flex w-80 flex-col gap-3">
      <div>
        <h3 className="text-sm font-medium">FastForge Studio</h3>
        <p className="text-sm text-muted-foreground">Project configuration</p>
      </div>
      <Separator />
      <p className="text-sm">Manage build targets and deployment settings.</p>
    </div>
  ),
}

export const Vertical: Story = {
  render: () => (
    <div className="flex h-5 items-center gap-3 text-sm">
      <span>Overview</span>
      <Separator orientation="vertical" />
      <span>Activity</span>
      <Separator orientation="vertical" />
      <span>Settings</span>
    </div>
  ),
}
