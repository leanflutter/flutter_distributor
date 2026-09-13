import { createFileRoute } from '@tanstack/react-router'
import { FlaskConicalIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute('/p/$projectId/_shell/tests/')({
  component: UnitTests,
})

function UnitTests() {
  const { t } = useI18n()
  return (
    <>
      <PageHeader crumbs={[{ label: t('Unit Tests') }]} />
      <PageBody>
        <PageTitle
          title={t('Unit Tests')}
          description={t(
            'The test suites defined for this project and their latest results.',
          )}
        />
        <EmptyState
          icon={FlaskConicalIcon}
          title={t('No tests yet')}
          description={t(
            'Test suites appear here once a run finishes. Each one can be analyzed from its detail page.',
          )}
        />
      </PageBody>
    </>
  )
}
