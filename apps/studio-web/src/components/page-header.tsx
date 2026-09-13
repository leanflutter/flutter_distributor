import * as React from 'react'
import { Link } from '@tanstack/react-router'
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from 'studio-ui/components/breadcrumb'
import { Separator } from 'studio-ui/components/separator'
import { SidebarTrigger } from 'studio-ui/components/sidebar'

import { LocaleMenu } from '#/components/locale-menu'
import { ThemeToggle } from '#/components/theme-toggle'

import type { LinkComponentProps } from '@tanstack/react-router'

export type Crumb = {
  label: string
  /** Omit to render the crumb as plain text — used for grouping segments that have no page. */
  link?: LinkComponentProps
}

export function PageHeader({
  crumbs,
  actions,
}: {
  crumbs: Array<Crumb>
  actions?: React.ReactNode
}) {
  return (
    <header className="flex h-16 shrink-0 items-center gap-2 border-b">
      <div className="flex min-w-0 flex-1 items-center gap-2 px-4">
        <SidebarTrigger className="-ml-1" />
        <Separator
          orientation="vertical"
          className="mr-2 data-vertical:h-4 data-vertical:self-auto"
        />
        <Breadcrumb>
          <BreadcrumbList>
            {crumbs.map((crumb, index) => {
              const isLast = index === crumbs.length - 1
              return (
                <React.Fragment key={crumb.label}>
                  <BreadcrumbItem className={isLast ? undefined : 'hidden md:block'}>
                    {isLast ? (
                      <BreadcrumbPage>{crumb.label}</BreadcrumbPage>
                    ) : crumb.link ? (
                      <BreadcrumbLink asChild>
                        <Link {...crumb.link}>{crumb.label}</Link>
                      </BreadcrumbLink>
                    ) : (
                      <span>{crumb.label}</span>
                    )}
                  </BreadcrumbItem>
                  {isLast ? null : (
                    <BreadcrumbSeparator className="hidden md:block" />
                  )}
                </React.Fragment>
              )
            })}
          </BreadcrumbList>
        </Breadcrumb>
      </div>
      {actions ? (
        <div className="flex shrink-0 items-center gap-2 px-4">{actions}</div>
      ) : null}
      <div className="flex shrink-0 items-center gap-1 pr-4">
        <ThemeToggle />
        <LocaleMenu />
      </div>
    </header>
  )
}
