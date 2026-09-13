import type { Meta, StoryObj } from "@storybook/react-vite"

import { Input } from "studio-ui/components/input"

const meta = {
  title: "UI/Input",
  component: Input,
  args: {
    placeholder: "Enter a value",
  },
  decorators: [
    (Story) => (
      <div className="w-80">
        <Story />
      </div>
    ),
  ],
} satisfies Meta<typeof Input>

export default meta
type Story = StoryObj<typeof meta>

export const Playground: Story = {}

export const States: Story = {
  render: () => (
    <div className="flex flex-col gap-3">
      <Input placeholder="Default" />
      <Input value="Read-only value" readOnly />
      <Input placeholder="Disabled" disabled />
      <Input placeholder="Invalid" aria-invalid />
      <Input type="file" aria-label="Upload file" />
    </div>
  ),
}
