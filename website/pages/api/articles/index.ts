import type { NextApiRequest, NextApiResponse } from "next";

import { Article, Result, PagedList } from "../../../interfaces";
import { localDb, paginate } from "../../../utils";

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<Result<PagedList<Article>>>
) {
  const { page = 1, perPage = 10, locale = "en" }: any = req.query;

  const items = localDb.getArticles(locale, "");
  const pagedList: PagedList<Article> = paginate(items, page, perPage);

  res.statusCode = 200;
  res.json({ code: 0, data: pagedList });
}
