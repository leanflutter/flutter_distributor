'use client'

import * as React from 'react'

import { Button } from 'studio-ui/components/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from 'studio-ui/components/dropdown-menu'
import { MoonIcon, SunIcon } from 'lucide-react'

import { useI18n } from '#/lib/i18n'

const MODE_STORAGE_KEY = 'fastforge-studio-theme'
const THEME_STORAGE_KEY = 'fastforge-studio-theme-name'

type Mode = 'light' | 'dark'
type ThemeName = 'default' | 'maple'

function initialMode(): Mode {
  const stored = window.localStorage.getItem(MODE_STORAGE_KEY)
  if (stored === 'dark' || stored === 'light') return stored
  return window.matchMedia('(prefers-color-scheme: dark)').matches
    ? 'dark'
    : 'light'
}

function initialTheme(): ThemeName {
  const stored = window.localStorage.getItem(THEME_STORAGE_KEY)
  return stored === 'maple' ? 'maple' : 'default'
}

function apply(mode: Mode, theme: ThemeName) {
  const root = document.documentElement
  root.classList.toggle('dark', mode === 'dark')
  if (theme === 'default') {
    delete root.dataset.theme
  } else {
    root.dataset.theme = theme
  }
  window.localStorage.setItem(MODE_STORAGE_KEY, mode)
  window.localStorage.setItem(THEME_STORAGE_KEY, theme)
}

/** Appearance menu for the top-right header: light/dark mode plus the color
 * theme (default shadcn or Maple). Client-only, like the app. */
export function ThemeToggle() {
  const { t } = useI18n()
  const [mode, setMode] = React.useState(initialMode)
  const [theme, setTheme] = React.useState(initialTheme)

  React.useEffect(() => {
    apply(mode, theme)
  }, [mode, theme])

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant="ghost"
          size="icon-sm"
          aria-label={t('Toggle theme')}
          title={t('Toggle theme')}
        >
          {mode === 'dark' ? <MoonIcon aria-hidden /> : <SunIcon aria-hidden />}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="min-w-40">
        <DropdownMenuLabel>{t('Appearance')}</DropdownMenuLabel>
        <DropdownMenuRadioGroup
          value={mode}
          onValueChange={(value) => setMode(value as Mode)}
        >
          <DropdownMenuRadioItem value="light">
            {t('Light')}
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="dark">{t('Dark')}</DropdownMenuRadioItem>
        </DropdownMenuRadioGroup>
        <DropdownMenuSeparator />
        <DropdownMenuLabel>{t('Theme')}</DropdownMenuLabel>
        <DropdownMenuRadioGroup
          value={theme}
          onValueChange={(value) => setTheme(value as ThemeName)}
        >
          <DropdownMenuRadioItem value="default">
            {t('Default')}
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="maple">Maple</DropdownMenuRadioItem>
        </DropdownMenuRadioGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
