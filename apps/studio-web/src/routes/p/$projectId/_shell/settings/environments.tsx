import { createFileRoute } from '@tanstack/react-router'
import { LayersIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/settings/environments')({
  component: SettingsEnvironments,
})

function SettingsEnvironments() {
  const { t } = useI18n()
  return (
    <>
      <PageBody>
        <PageTitle
          title={t('Environments')}
          description={t(
            'Flavors, build variables and the values that differ per environment.',
          )}
        />
        <EmptyState
          icon={LayersIcon}
          title={t('No environments configured')}
          description={t(
            'Define staging, production and any custom flavors, along with the build arguments each one passes.',
          )}
        />
      </PageBody>
    </>
  )
}
