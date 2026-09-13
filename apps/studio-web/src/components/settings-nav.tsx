'use client'

import { Link } from '@tanstack/react-router'

import { settingsNavGroups } from '#/lib/navigation'
import { useI18n } from '#/lib/i18n'

// Only the active row paints the 2px lane, so rows share one vertical line
// whether or not they are selected (Maple's settings-shell row treatment).
const rowClass =
  'relative flex items-center gap-2.5 rounded-md px-2.5 py-1.5 text-sm text-muted-foreground transition-colors hover:bg-accent/50 hover:text-foreground data-[status=active]:bg-accent data-[status=active]:font-medium data-[status=active]:text-accent-foreground data-[status=active]:before:absolute data-[status=active]:before:inset-y-1.5 data-[status=active]:before:left-0 data-[status=active]:before:w-0.5 data-[status=active]:before:rounded-full data-[status=active]:before:bg-primary'

/**
 * The settings sections as a secondary navigation column. The project sidebar
 * (primary) stays in place; this renders inside the settings pages.
 */
export function SettingsNav({ projectId }: { projectId: string }) {
  const { t } = useI18n()
  const groups = settingsNavGroups(projectId, t)

  return (
    <nav className="flex flex-col gap-5">
      {groups.map((group, index) => (
        <div key={group.label ?? index} className="flex flex-col gap-1">
          {group.label ? (
            <div className="px-2.5 text-[10px] font-medium tracking-[0.14em] text-muted-foreground/60 uppercase">
              {group.label}
            </div>
          ) : null}
          <div className="flex flex-col gap-0.5">
            {group.items.map((item) => (
              <Link key={item.title} {...item.link} className={rowClass}>
                <item.icon className="size-4 shrink-0" />
                {item.title}
              </Link>
            ))}
          </div>
        </div>
      ))}
    </nav>
  )
}
