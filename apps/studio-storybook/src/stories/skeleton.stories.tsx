import type { Meta, StoryObj } from "@storybook/react-vite"

import { Skeleton } from "studio-ui/components/skeleton"

const meta = {
  title: "UI/Skeleton",
  component: Skeleton,
} satisfies Meta<typeof Skeleton>

export default meta
type Story = StoryObj<typeof meta>

export const Card: Story = {
  render: () => (
    <div className="flex w-80 items-center gap-3 rounded-xl border p-4">
      <Skeleton className="size-10 rounded-full" />
      <div className="flex flex-1 flex-col gap-2">
        <Skeleton className="h-4 w-2/3" />
        <Skeleton className="h-3 w-full" />
      </div>
    </div>
  ),
}
