import React from "react";
import { Text, Container, ActionIcon, Group } from "@mantine/core";
import { BrandGithub, BrandDiscord } from "tabler-icons-react";

import useStyles from "./Footer.styles";

interface FooterProps {}

export function Footer(props: FooterProps) {
  const { classes } = useStyles();
  return (
    <footer className={classes.footer}>
      <Container className={classes.inner}>
        <Text color="dimmed" size="sm">
          © 2022 leanflutter.org. All rights reserved.
        </Text>
        <Group spacing={0} className={classes.social} position="right" noWrap>
          <a href="https://discord.com/invite/zPa6EZ2jqb" target="__blank">
            <ActionIcon size="lg">
              <BrandDiscord size={18} />
            </ActionIcon>
          </a>
          <a href="https://github.com/leanflutter" target="__blank">
            <ActionIcon size="lg">
              <BrandGithub size={18} />
            </ActionIcon>
          </a>
        </Group>
      </Container>
    </footer>
  );
}
