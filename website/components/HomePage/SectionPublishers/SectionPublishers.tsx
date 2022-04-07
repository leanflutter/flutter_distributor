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

import useStyles from "./SectionPublishers.styles";

export const MOCKDATA = [
  {
    title: "appstore",
    description: "Publish your app to appstore.",
  },
  {
    title: "fir",
    description: "Publish your app to fir.",
  },
  {
    title: "firebase",
    description: "Publish your app to firebase.",
  },
  {
    title: "github",
    description: "Publish your app to github release.",
  },
  {
    title: "pgyer",
    description: "Publish your app to pgyer.",
  },
  {
    title: "qiniu",
    description: "Publish your app to qiniu.",
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

interface SectionPublishersProps {}

export function SectionPublishers(props: SectionPublishersProps) {
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const features = MOCKDATA.map((feature, index) => (
    <Feature {...feature} key={index} />
  ));

  return (
    <div className={classes.wrapper}>
      <Container>
        <Title className={classes.title}>{"Supported Publishers"}</Title>
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
