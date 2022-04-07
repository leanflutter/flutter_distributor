import React, { useState } from "react";
import Link from "next/link";
import {
  Group,
  Box,
  Collapse,
  Text,
  UnstyledButton,
  createStyles,
} from "@mantine/core";
import {
  ChevronLeft,
  ChevronRight,
} from "tabler-icons-react";

import useStyles from "./LinksGroup.styles";

interface LinksGroupProps {
  label: string;
  initiallyOpened?: boolean;
  link?: string;
  links?: { label: string; link: string }[];
}

export function LinksGroup({
  label,
  initiallyOpened,
  link,
  links,
}: LinksGroupProps) {
  const { classes, theme } = useStyles();
  const hasLinks = Array.isArray(links);
  const [opened, setOpened] = useState(initiallyOpened || false);
  const ChevronIcon = theme.dir === "ltr" ? ChevronRight : ChevronLeft;

  const items = (hasLinks ? links : []).map((link) => (
    <Link
      href={link.link}
      key={link.label}
      passHref
    >
      <Text<"a">
        component="a"
        className={classes.link}
        href={link.link}
        key={link.label}
      >
        {link.label}
      </Text>
    </Link>
  ));

  if (!hasLinks) {
    return <>
      <Link
        href={link!}
        passHref
      >
        <UnstyledButton
          component="a"
          className={classes.control}

        >
          <Group position="apart" spacing={0}>
            <Box sx={{ display: "flex", alignItems: "center" }}>
              <Box ml="md">{label}</Box>
            </Box>
          </Group>
        </UnstyledButton>
      </Link>
    </>
  }

  return (
    <>
      <UnstyledButton
        onClick={() => setOpened((o) => !o)}
        className={classes.control}
      >
        <Group position="apart" spacing={0}>
          <Box sx={{ display: "flex", alignItems: "center" }}>
            <Box ml="md">{label}</Box>
          </Box>
          {hasLinks && (
            <ChevronIcon
              className={classes.chevron}
              size={14}
              style={{
                transform: opened
                  ? `rotate(${theme.dir === "rtl" ? -90 : 90}deg)`
                  : "none",
              }}
            />
          )}
        </Group>
      </UnstyledButton>
      {hasLinks ? <Collapse in={opened}>{items}</Collapse> : null}
    </>
  );
}
