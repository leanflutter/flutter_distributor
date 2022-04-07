import React, { useState } from "react";
import {
  Header as HeaderComp,
  Menu,
  Group,
  Center,
  Container,
  useMantineColorScheme,
  ActionIcon,
  Anchor,
} from "@mantine/core";
import { ChevronDown, MoonStars, Sun } from "tabler-icons-react";
import Link from "next/link";

import { LocaleSwitcher, Logo } from "../..";

import useStyles from "./Header.styles";

interface HeaderProps {
  links: {
    link: string;
    label: string;
    links: { link: string; label: string }[];
  }[];
}

export function Header({ links }: HeaderProps) {
  const { classes, theme, cx } = useStyles();
  const { colorScheme, toggleColorScheme } = useMantineColorScheme();

  const items = links.map((link) => {
    const menuItems = link.links?.map((item) => (
      <Menu.Item component="a" key={item.link} href={item.link}>
        {item.label}
      </Menu.Item>
    ));

    if (menuItems.length > 0) {
      return (
        <Menu
          key={link.label}
          trigger="hover"
          delay={0}
          transitionDuration={0}
          placement="end"
          gutter={1}
          control={
            <a
              href={link.link}
              className={classes.link}
              onClick={(event) => event.preventDefault()}
            >
              <Center>
                <span className={classes.linkLabel}>{link.label}</span>
                <ChevronDown size={12} />
              </Center>
            </a>
          }
        >
          {menuItems}
        </Menu>
      );
    }

    return (
      <Link key={link.label} href={link.link}>
        <a className={classes.link}>{link.label}</a>
      </Link>
    );
  });

  return (
    <HeaderComp height={56} fixed>
      <Container fluid>
        <div className={classes.inner}>
          <Link href="/" passHref>
            <Anchor style={{ textDecoration: "none" }}>
              <Logo />
            </Anchor>
          </Link>
          <Group ml={60} spacing={5} className={classes.links}>
            {items}
          </Group>
          <div style={{ flex: 1 }} />
          <LocaleSwitcher />
          <Group position="center" my="xl" ml={20}>
            <ActionIcon
              onClick={() => toggleColorScheme()}
              size="lg"
              sx={(theme) => ({
                backgroundColor:
                  theme.colorScheme === "dark"
                    ? theme.colors.dark[6]
                    : theme.colors.gray[0],
                color:
                  theme.colorScheme === "dark"
                    ? theme.colors.yellow[4]
                    : theme.colors.indigo[6],
              })}
            >
              {colorScheme === "dark" ? (
                <Sun size={18} />
              ) : (
                <MoonStars size={18} />
              )}
            </ActionIcon>
          </Group>
        </div>
      </Container>
    </HeaderComp>
  );
}
