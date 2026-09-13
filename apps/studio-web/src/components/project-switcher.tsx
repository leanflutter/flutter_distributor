'use client'

import * as React from 'react'
import { Link } from '@tanstack/react-router'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from 'studio-ui/components/dropdown-menu'
import { Input } from 'studio-ui/components/input'
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from 'studio-ui/components/sidebar'
import { CheckIcon, ChevronsUpDownIcon, LayoutGridIcon } from 'lucide-react'

import { BrandIcon } from '#/components/brand-icon'
import { useI18n } from '#/lib/i18n'

import type { ProjectSummary } from 'studio-api-client'
import type { Project } from '#/lib/workspace'

export function ProjectSwitcher({
  project,
  projects,
}: {
  project: Project
  projects: Array<ProjectSummary>
}) {
  const { isMobile } = useSidebar()
  const { t } = useI18n()
  const [query, setQuery] = React.useState('')

  const matches = projects.filter((candidate) =>
    candidate.name.toLowerCase().includes(query.trim().toLowerCase()),
  )

  // There is no workspace above a project yet, so the second line shows where
  // the project actually lives instead.
  const subtitle = project.path ?? project.repo

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu onOpenChange={() => setQuery('')}>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton
              size="lg"
              className="data-[state=open]:bg-sidebar-accent data-[state=open]:text-sidebar-accent-foreground"
            >
              <BrandIcon className="size-8! shrink-0" />
              <div className="grid flex-1 text-left text-sm leading-tight">
                <span className="truncate font-medium">{project.name}</span>
                <span className="truncate text-xs text-muted-foreground">
                  {subtitle}
                </span>
              </div>
              <ChevronsUpDownIcon className="ml-auto" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            className="w-(--radix-dropdown-menu-trigger-width) min-w-64"
            align="start"
            side={isMobile ? 'bottom' : 'right'}
            sideOffset={4}
          >
            <DropdownMenuLabel className="text-xs text-muted-foreground">
              {t('Projects')}
            </DropdownMenuLabel>
            <div className="px-1 pb-1">
              <Input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                // Radix runs its own typeahead on menu content; without this the
                // first keystroke jumps focus to a matching item. Arrow keys are
                // left alone so they still move into the filtered list.
                onKeyDown={(event) => {
                  if (!event.key.startsWith('Arrow')) {
                    event.stopPropagation()
                  }
                }}
                placeholder={t('Search projects…')}
                className="h-8"
              />
            </div>
            {matches.length === 0 ? (
              <p className="px-2 py-3 text-center text-sm text-muted-foreground">
                {t('No matching project')}
              </p>
            ) : (
              matches.map((candidate) => (
                <DropdownMenuItem key={candidate.id} asChild>
                  <Link to="/p/$projectId" params={{ projectId: candidate.id }}>
                    <span className="flex-1 truncate">{candidate.name}</span>
                    {candidate.id === project.id ? (
                      <CheckIcon className="text-muted-foreground" />
                    ) : null}
                  </Link>
                </DropdownMenuItem>
              ))
            )}

            <DropdownMenuSeparator />
            <DropdownMenuItem asChild>
              <Link to="/">
                <LayoutGridIcon className="text-muted-foreground" />
                <span>{t('All projects')}</span>
              </Link>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}
