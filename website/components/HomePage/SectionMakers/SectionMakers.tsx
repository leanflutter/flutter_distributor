import React from "react";
import {
  Text,
  SimpleGrid,
  Container,
  Title,
  useMantineTheme,
  ThemeIcon,
} from "@mantine/core";
import { Gauge, Cookie, User, Message2, Lock } from "tabler-icons-react";
import { Icon as TablerIcon } from "tabler-icons-react";

import useStyles from "./SectionMakers.styles";

export const MOCKDATA = [
  {
    title: "apk",
    description: "Create a apk package for your app.",
  },
  {
    title: "aab",
    description: "Create a aab package for your app.",
  },
  {
    title: "deb",
    description: "Create a deb package for your app.",
  },
  {
    title: "dmg",
    description: "Create a dmg package for your app.",
  },
  {
    title: "exe",
    description: "Create a exe package for your app.",
  },
  {
    title: "ipa",
    description: "Create a ipa package for your app.",
  },
  {
    title: "zip",
    description: "Create a zip package for your app.",
  },
];

interface FeatureProps {
  title: React.ReactNode;
  description: React.ReactNode;
}

export function Feature({ title, description }: FeatureProps) {
  const theme = useMantineTheme();
  return (
    <div>
      <Text style={{ marginTop: theme.spacing.sm, marginBottom: 7 }}>
        {title}
      </Text>
      <Text size="sm" color="dimmed" style={{ lineHeight: 1.6 }}>
        {description}
      </Text>
    </div>
  );
}

interface SectionMakersProps {}

export function SectionMakers(props: SectionMakersProps) {
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const features = MOCKDATA.map((feature, index) => (
    <Feature {...feature} key={index} />
  ));

  return (
    <div className={classes.wrapper}>
      <Container>
        <Title className={classes.title}>{"Supported Makers"}</Title>
        <SimpleGrid
          mt={60}
          cols={3}
          spacing={theme.spacing.xl * 2}
          breakpoints={[
            { maxWidth: 980, cols: 2, spacing: "xl" },
            { maxWidth: 755, cols: 1, spacing: "xl" },
          ]}
        >
          {features}
        </SimpleGrid>
      </Container>
    </div>
  );
}
