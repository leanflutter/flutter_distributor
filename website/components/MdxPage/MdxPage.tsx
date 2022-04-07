import { Divider, Title } from "@mantine/core";
import { useTranslation } from "next-i18next";
import { Layout } from "..";
import { Article } from "../../interfaces";

import { Navbar } from "./Navbar";


import useStyles from "./MdxPage.styles";

import { MdxContent } from "./MdxContent";
import { TableOfContents } from "./TableOfContents";

interface MdxPageProps {
  article: Article;
}

export function MdxPage(props: MdxPageProps) {
  const { classes } = useStyles();
  const { t } = useTranslation("common");
  const { article } = props;
  return (
    <Layout
      title={`${article.title} - ${t("name")}`}
      description={`${article.title} - ${t("name")}`}
    >
      <div className={classes.wrapper}>
        <Navbar />
        <div className={classes.container}>
          <Title>{article.title}</Title>
          <Divider my={24} variant="dotted" />
          <MdxContent article={article} />
        </div>
        <div className={classes.tableOfContents}>
          {/* <TableOfContents headings={article?.headings || []} withTabs={false} /> */}
        </div>
      </div>
    </Layout>
  );
}
