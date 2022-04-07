import React from "react";
import { useRouter } from "next/router";
import Link from "next/link";
import Image from "next/image";
import { useTranslation } from "next-i18next";
import {
  Group,
  Menu,
  Text,
  UnstyledButton,
} from "@mantine/core";
import { ChevronDown } from "tabler-icons-react";
import useStyles from "./LocaleSwitcher.styles";

export function LocaleSwitcher() {
  const { classes } = useStyles();
  const router = useRouter();

  const { t } = useTranslation("common");

  const { locales, locale: activeLocale } = router;

  return (
    <Menu
      placement="end"
      transition="pop-top-right"
      control={
        <UnstyledButton>
          <Group spacing={7}>
            <Image
              src={`/images/flags/${activeLocale}.svg`}
              width={20}
              height={20}
              alt=""
            />
            <Text weight={500} size="sm" sx={{ lineHeight: 1 }} mr={3}>
              {t(`language.${activeLocale}`)}
            </Text>
            <ChevronDown size={12} />
          </Group>
        </UnstyledButton>
      }
    >
      {(locales || []).map((locale) => {
        const { pathname, query, asPath } = router;
        return (
          <Link
            key={locale}
            href={{ pathname, query }}
            as={asPath}
            locale={locale}
            passHref
          >
            <Menu.Item key={locale}>
              <Group spacing={7}>
                <Image
                  src={`/images/flags/${locale}.svg`}
                  width={20}
                  height={20}
                  alt=""
                />
                <Text weight={500} size="sm" sx={{ lineHeight: 1 }} mr={3}>
                  {t(`language.${locale}`)}
                </Text>
              </Group>
            </Menu.Item>
          </Link>
        );
      })}
    </Menu>
  );
}
