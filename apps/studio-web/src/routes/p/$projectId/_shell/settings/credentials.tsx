import { createFileRoute } from '@tanstack/react-router'
import { KeyIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/settings/credentials')({
  component: SettingsCredentials,
})

function SettingsCredentials() {
  const { t } = useI18n()
  return (
    <>
      <PageBody>
        <PageTitle
          title={t('Credentials')}
          description={t(
            'Signing keys and the API credentials stores and publishers authenticate with.',
          )}
        />
        <EmptyState
          icon={KeyIcon}
          title={t('No credentials stored')}
          description={t(
            'Keystores, App Store Connect keys and service accounts are referenced by name from the configuration.',
          )}
        />
      </PageBody>
    </>
  )
}
