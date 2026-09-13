'use client'

import { Button } from 'studio-ui/components/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuTrigger,
} from 'studio-ui/components/dropdown-menu'
import { LanguagesIcon } from 'lucide-react'

import { useI18n } from '#/lib/i18n'

/** Language picker for the top-right header. Nothing about a user's account. */
export function LocaleMenu() {
  const { locale, setLocale, t } = useI18n()

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant="ghost"
          size="icon-sm"
          aria-label={t('Language')}
          title={t('Language')}
        >
          <LanguagesIcon />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="min-w-40">
        <DropdownMenuRadioGroup
          value={locale}
          onValueChange={(value) =>
            setLocale(value as 'en' | 'zh-CN' | 'ja' | 'ko')
          }
        >
          <DropdownMenuRadioItem value="en">{t('English')}</DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="zh-CN">
            {t('简体中文')}
          </DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="ja">{t('日本語')}</DropdownMenuRadioItem>
          <DropdownMenuRadioItem value="ko">{t('한국어')}</DropdownMenuRadioItem>
        </DropdownMenuRadioGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
