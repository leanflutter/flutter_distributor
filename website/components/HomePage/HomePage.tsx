import { useTranslation } from "next-i18next";
import { Layout } from "..";

import { SectionMakers } from "./SectionMakers/SectionMakers";
import { SectionJumbotron } from "./SectionJumbotron/SectionJumbotron";
import { SectionPartyPopper } from "./SectionPartyPopper/SectionPartyPopper";
import { SectionPublishers } from "./SectionPublishers/SectionPublishers";

export function HomePage() {
  const { t } = useTranslation("common");
  return (
    <Layout
      title={`${t("name")} - ${t("slogan")}`}
      description={`${t("name")} - ${t("slogan")}`}
    >
      <SectionJumbotron />
      <SectionMakers />
      <SectionPublishers />
      <SectionPartyPopper />
    </Layout>
  );
}
