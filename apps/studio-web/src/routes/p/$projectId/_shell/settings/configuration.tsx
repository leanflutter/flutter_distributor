import { createFileRoute } from '@tanstack/react-router'
import { FileCodeIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/settings/configuration')({
  component: SettingsConfiguration,
})

function SettingsConfiguration() {
  const { t } = useI18n()
  return (
    <>
      <PageBody>
        <PageTitle
          title={t('Configuration')}
          description={t(
            'The raw .fastforge/config.yaml. Every form on the other pages is a view onto this file.',
          )}
        />
        <EmptyState
          icon={FileCodeIcon}
          title="config.yaml"
          description={t(
            'An editor for the file itself, so anything the forms do not cover stays reachable.',
          )}
        />
      </PageBody>
    </>
  )
}
