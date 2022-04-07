import React from "react";
import Image from "next/image";
import { useTranslation } from "next-i18next";

import useStyles from "./Logo.styles";

interface LogoProps {}

export function Logo({}: LogoProps) {
  const { classes } = useStyles();
  const { t } = useTranslation("common");
  return (
    <div className={classes.logo}>
      <Image
        className={classes.image}
        src="/images/logo.png"
        width={32}
        height={32}
        alt=""
      />
      <span className={classes.title}>{t("name")}</span>
    </div>
  );
}
