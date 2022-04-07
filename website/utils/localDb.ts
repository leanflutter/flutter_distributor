import fs from "fs";
import { join } from "path";
import matter from "gray-matter";

import { Article, PagedList } from "../interfaces";

const sourceDir = join(`${process.cwd()}`, "_source");

export const paginate = (items: Array<any>, page: number, perPage: number) => {
  const total = items.length;
  const lastPage = Math.ceil(total / perPage);

  const from = (page - 1) * perPage;
  const to = from + (perPage - 1);

  const pagedList: PagedList<any> = {
    total,
    currentPage: page,
    lastPage,
    perPage: perPage,
    items: items.slice(from, to + 1),
  };
  return pagedList;
};

export class LocalDb {
  getArticleByPath(locale: string, path: any): Article {
    const filePath = `${sourceDir}/${locale}/${path}`;
    const fileContents = fs.readFileSync(filePath, "utf8");
    const { data, content } = matter(fileContents);
    let article: Article = {
      path,
      ...data,
      content,
    };
    return article;
  }

  getArticles(locale: string, path: string = ""): Array<Article> {
    const dir = `${sourceDir}/${locale}/${path}`;
    return fs.readdirSync(dir).flatMap((item: any) => {
      if (fs.statSync(`${dir}/${item}`).isDirectory()) {
        return this.getArticles(locale, `${path}/${item}`);
      }
      return this.getArticleByPath(locale, `${path}/${item}`);
    });
  }
}

export const localDb = new LocalDb();
