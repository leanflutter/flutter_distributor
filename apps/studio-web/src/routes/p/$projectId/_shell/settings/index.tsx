import { createFileRoute } from '@tanstack/react-router'
import { SlidersHorizontalIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/settings/')({
  component: SettingsGeneral,
})

function SettingsGeneral() {
  const { t } = useI18n()
  return (
    <>
      <PageBody>
        <PageTitle
          title={t('General')}
          description={t(
            'Project name, identifiers and the location Fastforge reads its config from.',
          )}
        />
        <EmptyState
          icon={SlidersHorizontalIcon}
          title={t('General settings')}
          description={t(
            'Display name, application id and the path to this project on disk.',
          )}
        />
      </PageBody>
    </>
  )
}
