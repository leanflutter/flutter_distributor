import { Link, createFileRoute } from '@tanstack/react-router'
import { api } from 'studio-api-client'
import { PackageIcon } from 'lucide-react'

import { AuthFieldList, AuthStatusBadge } from '#/components/auth-status-badge'
import { PageBody, PageTitle } from '#/components/page-body'
import { PageHeader } from '#/components/page-header'
import { useI18n } from '#/lib/i18n'

import type { StoreApp, StoreConnection } from 'studio-api-client'

export const Route = createFileRoute('/p/$projectId/_shell/stores/')({
  loader: async ({ params }) => {
    const [connections, apps] = await Promise.all([
      api.listStores(params.projectId),
      api.listStoreApps(params.projectId),
    ])
    return { connections, apps }
  },
  component: Stores,
})

function Stores() {
  const { projectId } = Route.useParams()
  const { connections, apps } = Route.useLoaderData()
  const { t } = useI18n()

  return (
    <>
      <PageHeader crumbs={[{ label: t('Stores') }]} />
      <PageBody>
        <PageTitle
          title={t('Stores')}
          description={t(
            'Storefronts that own the listing: versions, tracks, review state and catalog metadata.',
          )}
        />

        <div className="space-y-4">
          {connections.map((connection) => (
            <StoreCard
              key={connection.store}
              projectId={projectId}
              connection={connection}
              apps={apps.filter((app) => app.store === connection.store)}
            />
          ))}
        </div>

        <p className="text-xs text-muted-foreground">
          Stores and their apps are read from{' '}
          <code className="font-mono">.fastforge/config.yaml</code>. Credentials
          come from the environment — Studio only reports whether they resolve,
          never their values.
        </p>
      </PageBody>
    </>
  )
}

function StoreCard({
  projectId,
  connection,
  apps,
}: {
  projectId: string
  connection: StoreConnection
  apps: Array<StoreApp>
}) {
  const { t } = useI18n()
  return (
    <section className="rounded-xl border bg-card">
      <header className="flex items-start gap-4 p-4">
        <div className="min-w-0 flex-1">
          <Link
            to="/p/$projectId/stores/$storeId"
            params={{ projectId, storeId: connection.store }}
            className="font-medium hover:underline"
          >
            {connection.name}
          </Link>
          <p className="text-sm text-muted-foreground">
            {connection.description}
          </p>
          <AuthFieldList status={connection.authStatus} />
        </div>
        <AuthStatusBadge status={connection.authStatus} />
      </header>

      {!connection.configured ? (
        <p className="border-t px-4 py-3 text-sm text-muted-foreground">
          Add a <code className="font-mono">{connection.store}</code> section to{' '}
          <code className="font-mono">.fastforge/config.yaml</code> to connect
          this store.
        </p>
      ) : apps.length === 0 ? (
        <p className="border-t px-4 py-3 text-sm text-muted-foreground">
          {t('No apps registered under this store.')}
        </p>
      ) : (
        <ul className="divide-y border-t">
          {apps.map((app) => (
            <li key={app.id}>
              <Link
                to="/p/$projectId/stores/$storeId"
                params={{ projectId, storeId: app.store }}
                search={{ app: app.id }}
                className="flex items-center gap-4 px-4 py-3 transition-colors hover:bg-muted/40"
              >
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-medium">
                    {app.name ?? app.identifier}
                  </p>
                  <p className="truncate font-mono text-xs text-muted-foreground">
                    {app.identifier}
                    {app.appId ? ` · ${app.appId}` : ''}
                    {app.track ? ` · ${app.track}` : ''}
                  </p>
                </div>
                <span className="flex shrink-0 items-center gap-1.5 text-xs text-muted-foreground">
                  <PackageIcon className="size-3.5" />
                  {app.catalog.exists
                    ? t('{count} catalog files', {
                        count: app.catalog.fileCount,
                      })
                    : t('Not pulled')}
                </span>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </section>
  )
}
