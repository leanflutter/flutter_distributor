'use client'

import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from 'studio-ui/components/sidebar'
import { BookOpenIcon } from 'lucide-react'

import { useI18n } from '#/lib/i18n'

/** Documentation link, pinned to the very bottom of the sidebar. */
export function NavDoc() {
  const { t } = useI18n()

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <SidebarMenuButton size="lg" tooltip={t('Documentation')} asChild>
          <a
            href="https://fastforge.dev/docs"
            target="_blank"
            rel="noreferrer"
          >
            <BookOpenIcon />
            <span>{t('Documentation')}</span>
          </a>
        </SidebarMenuButton>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}
