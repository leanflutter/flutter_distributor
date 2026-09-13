import { createFileRoute } from '@tanstack/react-router'
import { CloudUploadIcon } from 'lucide-react'

import { EmptyState, PageBody, PageTitle } from '#/components/page-body'
import { useI18n } from '#/lib/i18n'

export const Route = createFileRoute(
  '/p/$projectId/_shell/settings/publishers/$publisherId',
)({
  component: PublisherDetail,
})

function PublisherDetail() {
  const { publisherId } = Route.useParams()
  const { t } = useI18n()

  return (
    <>
      <PageBody>
        <PageTitle
          title={publisherId}
          description={t(
            'Credentials and target options for this publisher, plus what has been uploaded to it.',
          )}
        />
        <EmptyState
          icon={CloudUploadIcon}
          title={t('Publisher target')}
          description={t(
            'Target options, the credential it authenticates with, and its upload history.',
          )}
        />
      </PageBody>
    </>
  )
}
