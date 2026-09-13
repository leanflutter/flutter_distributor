import { createFileRoute } from '@tanstack/react-router'
import { HammerIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/settings/build')({
  component: SettingsBuild,
})

function SettingsBuild() {
  const { t } = useI18n()
  return (
    <>
      <PageBody>
        <PageTitle
          title={t('Build & Package')}
          description={t(
            'Which builder runs, and which package formats it produces.',
          )}
        />
        <EmptyState
          icon={HammerIcon}
          title={t('Builders and packagers')}
          description={t(
            'Flutter, Gradle, Xcode or a custom builder, and the APK / AAB / IPA / DMG / PKG targets built from it.',
          )}
        />
      </PageBody>
    </>
  )
}
