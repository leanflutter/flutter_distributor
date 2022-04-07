import React from 'react';
import Link from 'next/link';
import { Code, Table, Title, Text } from '@mantine/core';
import { Prism } from '@mantine/prism';
import { MDXRemote } from 'next-mdx-remote';
import { Article } from '../../../interfaces';

const preToPrismBlock = (preProps: any) => {
  if (
    preProps.children &&
    preProps.children?.props
  ) {
    const {
      children: codeString,
      className = '',
    } = preProps?.children?.props;

    const match = className.match(/language-([\0-\uFFFF]*)/);

    return {
      children: codeString.trim(),
      language: match != null ? match[1] : '',
    };
  }
  return undefined;
};


interface DataTableProps {
  children: React.ReactNode[][];
}

export default function DataTable({ children }: DataTableProps) {
  return (
    <Table>
      {children}
    </Table>
  );
}

interface MdxContentProps {
  article: Article;
}

export const MdxContent = ({
  article,
}: MdxContentProps) => {
  return (
    <MDXRemote
      {...article.mdxContent}
      components={{
        table: (props: any) => {
          return <DataTable {...props} />
        },
        h1: (props: any) => {
          return <Title order={1} my="md" {...props} />;
        },
        h2: (props: any) => {
          return <Title order={2} my="md" {...props} />;
        },
        h3: (props: any) => {
          return <Title order={3} my="md" {...props} />;
        },
        h4: (props: any) => {
          return <Title order={4} my="md" {...props} />;
        },
        h5: (props: any) => {
          return <Title order={5} my="md" {...props} />;
        },
        inlineCode: (props: any) => <Code {...props} />,
        a: ({ href, children }: { href: string; children: string }) => {
          const replaced = href.replace('https://mantine.dev', '');

          if (!replaced.startsWith('http') && replaced.trim().length > 0) {
            return <Link href={href.replace('https://mantine.dev', '')}>{children}</Link>;
          }

          return (
            <Text component="a" variant="link" href={href}>
              {children}
            </Text>
          );
        },
        p: (props: any) => <p {...props} style={{ lineHeight: 1.55 }} />,
        ul: (props: any) => (
          <ul {...props} style={{ lineHeight: 1.65, marginBottom: 20, marginTop: 10 }} />
        ),
        li: (props: any) => <li {...props} style={{ marginTop: 4 }} />,
        pre: (props: any) => {
          const prismProps = preToPrismBlock(props);
          if (prismProps) {
            return <Prism {...prismProps} />;
          }
          return <pre {...props} />;
        },
      }}
    />
  );
};
