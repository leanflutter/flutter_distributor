import React from "react";
import Head from "next/head";
import { AppShell } from "@mantine/core";

import { Footer } from "./Footer";
import { Header } from "./Header";

interface LayoutProps {
  title?: string;
  description?: string;
  children?: any;
}

export function Layout({ title, description, children }: LayoutProps) {
  return (
    <>
      <Head>
        <title>{title}</title>
        <meta name="description" content={description} />
      </Head>
      <div>
        <AppShell
          header={
            <Header
              links={[]}
            />
          }
          padding={0}
        >
          <div style={{ marginTop: 56 }}>{children}</div>
          <Footer />
        </AppShell>
      </div>
    </>
  );
}
