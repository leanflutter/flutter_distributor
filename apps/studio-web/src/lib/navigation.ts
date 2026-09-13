import { linkOptions } from '@tanstack/react-router'
import {
  ActivityIcon,
  CloudUploadIcon,
  FileCodeIcon,
  FlaskConicalIcon,
  HammerIcon,
  KeyIcon,
  LayersIcon,
  LayoutDashboardIcon,
  PackageIcon,
  RocketIcon,
  SlidersHorizontalIcon,
  StoreIcon,
  WorkflowIcon,
} from 'lucide-react'

import type { LinkComponentProps } from '@tanstack/react-router'
import type { LucideIcon } from 'lucide-react'
import type { StoreConnection } from 'studio-api-client'
import type { Capabilities } from '#/lib/capabilities'

type Translate = (key: string) => string

export type NavSubItem = {
  title: string
  link: LinkComponentProps
}

export type NavItem = {
  title: string
  icon: LucideIcon
  link: LinkComponentProps
  badge?: string
  /** Rendered as a collapsible sub-list, expanded by default. */
  items?: Array<NavSubItem>
}

export type NavGroup = {
  label?: string
  items: Array<NavItem>
}

/**
 * The project sidebar. One level only — anything deeper belongs to the page
 * it lives under, so adding a store or a publisher never grows the sidebar.
 */
export function projectNavGroups(
  projectId: string,
  capabilities: Capabilities,
  stores: Array<StoreConnection>,
  t: Translate = (key) => key,
): Array<NavGroup> {
  return [
    {
      items: [
        {
          title: t('Overview'),
          icon: LayoutDashboardIcon,
          link: linkOptions({
            to: '/p/$projectId',
            params: { projectId },
            activeOptions: { exact: true },
          }),
        },
      ],
    },
    {
      // What produces things: definitions, executions, outputs.
      label: t('Build'),
      items: [
        {
          title: t('Workflows'),
          icon: WorkflowIcon,
          link: linkOptions({
            to: '/p/$projectId/workflows',
            params: { projectId },
          }),
        },
        {
          title: t('Runs'),
          icon: ActivityIcon,
          // Only the hosted service queues runs; locally they execute inline.
          badge: capabilities.runQueue ? '3' : undefined,
          link: linkOptions({
            to: '/p/$projectId/runs',
            params: { projectId },
          }),
        },
        {
          title: t('Artifacts'),
          icon: PackageIcon,
          link: linkOptions({
            to: '/p/$projectId/artifacts',
            params: { projectId },
          }),
        },
      ],
    },
    {
      // Where the project verifies what it built.
      label: t('Test'),
      items: [
        {
          title: t('Unit Tests'),
          icon: FlaskConicalIcon,
          link: linkOptions({
            to: '/p/$projectId/tests',
            params: { projectId },
          }),
        },
      ],
    },
    {
      // Where things go. Only surfaces with ongoing state live here: a store
      // has versions, tracks and review status to watch. Publishers are just
      // upload targets, so they sit in settings alongside the rest of the
      // configuration.
      label: t('Distribute'),
      items: [
        {
          title: t('Stores'),
          icon: StoreIcon,
          // Exact, so a connected store below only highlights its own row.
          link: linkOptions({
            to: '/p/$projectId/stores',
            params: { projectId },
            activeOptions: { exact: true },
          }),
          // Only the stores this project has configured. Each one is a
          // storefront, not an app: the apps under it live on its own page, so
          // registering another never grows the sidebar.
          items: stores
            .filter((store) => store.configured)
            .map((store) => ({
              title: store.name,
              link: linkOptions({
                to: '/p/$projectId/stores/$storeId',
                params: { projectId, storeId: store.store },
              }),
            })),
        },
        {
          title: t('Releases'),
          icon: RocketIcon,
          link: linkOptions({
            to: '/p/$projectId/releases',
            params: { projectId },
          }),
        },
      ],
    },
  ]
}

/**
 * Settings renders as a secondary sidebar inside the settings pages (see
 * settings-nav.tsx); the project sidebar stays in place. Only project
 * settings are shown — the workspace-level settings have no home on a
 * local-only service.
 */
export function settingsNavGroups(
  projectId: string,
  t: Translate = (key) => key,
): Array<NavGroup> {
  const groups: Array<NavGroup> = []

  groups.push({
      label: t('Project'),
      items: [
        {
          title: t('General'),
          icon: SlidersHorizontalIcon,
          link: linkOptions({
            to: '/p/$projectId/settings',
            params: { projectId },
            activeOptions: { exact: true },
          }),
        },
        {
          title: t('Build & Package'),
          icon: HammerIcon,
          link: linkOptions({
            to: '/p/$projectId/settings/build',
            params: { projectId },
          }),
        },
        {
          title: t('Environments'),
          icon: LayersIcon,
          link: linkOptions({
            to: '/p/$projectId/settings/environments',
            params: { projectId },
          }),
        },
        {
          title: t('Credentials'),
          icon: KeyIcon,
          link: linkOptions({
            to: '/p/$projectId/settings/credentials',
            params: { projectId },
          }),
        },
        {
          title: t('Publishers'),
          icon: CloudUploadIcon,
          link: linkOptions({
            to: '/p/$projectId/settings/publishers',
            params: { projectId },
          }),
        },
        {
          title: t('Configuration'),
          icon: FileCodeIcon,
          link: linkOptions({
            to: '/p/$projectId/settings/configuration',
            params: { projectId },
          }),
        },
      ],
    })

  return groups
}
