import type { GetStaticPropsContext } from "next";
import { serverSideTranslations } from "next-i18next/serverSideTranslations";
import { serialize } from 'next-mdx-remote/serialize'
import remarkGfm from "remark-gfm";
import { MdxPage } from "../../../components";
import { Article } from "../../../interfaces";
import { localDb } from "../../../utils";
import rehypeExtractHeadings from "../../../utils/rehypeExtractHeadings";

export default function DocsDetailPage(props: any) {
  if (!props.article) {
    return <div />
  }
  return <MdxPage {...props} />;
}

export async function getStaticPaths({ locales }: any) {
  const paths: Array<any> = [];
  for (let i = 0; i < locales.length; i++) {
    const locale = locales[i];
    const articles: Array<Article> = await localDb.getArticles(locale, "docs");
    for (let j = 0; j < articles.length; j++) {
      const article: Article = articles[j];
      paths.push({
        params: {
          slug: article.path?.replace(`docs/`, "").replace(".md", "")?.split("/")
        },
        locale
      });
    }
  }
  return { paths, fallback: true };
}

export async function getStaticProps({
  locale,
  params,
}: GetStaticPropsContext) {
  const article = localDb.getArticleByPath(
    locale!,
    `docs/${(params?.slug as [] || []).join('/')}.md`
  );
  const headings: any[] = [];
  const mdxContent = await serialize(article.content || "", {
    mdxOptions: {
      remarkPlugins: [
        [remarkGfm],
      ],
      rehypePlugins: [
        [rehypeExtractHeadings, { rank: 2, headings }],
      ],
    },
  })
  return {
    props: {
      ...(await serverSideTranslations(locale!, ["common"])),
      params,
      article: { ...article, mdxContent, headings },
    },
  };
}
