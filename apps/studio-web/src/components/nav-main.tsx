'use client'

import { Link } from '@tanstack/react-router'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from 'studio-ui/components/collapsible'
import {
  SidebarGroup,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuAction,
  SidebarMenuBadge,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarMenuSub,
  SidebarMenuSubButton,
  SidebarMenuSubItem,
} from 'studio-ui/components/sidebar'
import { ChevronRightIcon } from 'lucide-react'

import type { NavGroup, NavItem } from '#/lib/navigation'

// The menu button renders as the link itself, so it carries the `data-status`
// TanStack Router puts on active links. Keying the active styles off that
// avoids re-deriving the active route from the pathname.
export const navActiveStyles =
  'data-[status=active]:bg-sidebar-accent data-[status=active]:font-medium data-[status=active]:text-sidebar-accent-foreground'

export function NavMain({ groups }: { groups: Array<NavGroup> }) {
  return (
    <>
      {groups.map((group, index) => (
        <SidebarGroup key={group.label ?? index}>
          {group.label ? (
            <SidebarGroupLabel>{group.label}</SidebarGroupLabel>
          ) : null}
          <SidebarMenu>
            {group.items.map((item) =>
              item.items?.length ? (
                <CollapsibleNavItem key={item.title} item={item} />
              ) : (
                <SidebarMenuItem key={item.title}>
                  <NavButton item={item} />
                  {item.badge ? (
                    <SidebarMenuBadge>{item.badge}</SidebarMenuBadge>
                  ) : null}
                </SidebarMenuItem>
              ),
            )}
          </SidebarMenu>
        </SidebarGroup>
      ))}
    </>
  )
}

function NavButton({ item }: { item: NavItem }) {
  return (
    <SidebarMenuButton asChild tooltip={item.title} className={navActiveStyles}>
      <Link {...item.link}>
        <item.icon />
        <span>{item.title}</span>
      </Link>
    </SidebarMenuButton>
  )
}

function CollapsibleNavItem({ item }: { item: NavItem }) {
  return (
    // Uncontrolled and open by default: the sub-list is the point of the item,
    // but collapsing it should stick for the rest of the session.
    <Collapsible asChild defaultOpen>
      <SidebarMenuItem>
        <NavButton item={item} />
        <CollapsibleTrigger asChild>
          <SidebarMenuAction className="data-[state=open]:rotate-90">
            <ChevronRightIcon />
            <span className="sr-only">Toggle {item.title}</span>
          </SidebarMenuAction>
        </CollapsibleTrigger>
        <CollapsibleContent>
          <SidebarMenuSub>
            {item.items?.map((subItem) => (
              <SidebarMenuSubItem key={subItem.title}>
                <SidebarMenuSubButton asChild className={navActiveStyles}>
                  <Link {...subItem.link}>
                    <span>{subItem.title}</span>
                  </Link>
                </SidebarMenuSubButton>
              </SidebarMenuSubItem>
            ))}
          </SidebarMenuSub>
        </CollapsibleContent>
      </SidebarMenuItem>
    </Collapsible>
  )
}
