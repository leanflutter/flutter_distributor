import React from "react";
import { Text, Container } from "@mantine/core";
import useStyles from "./SectionPartyPopper.styles";

interface SectionPartyPopperProps {}

export function SectionPartyPopper(props: SectionPartyPopperProps) {
  const { classes } = useStyles();

  return (
    <div className={classes.wrapper}>
      <Container px="md">
        <div className={classes.body}>
          <Text>🎉 🎉 🎉</Text>
        </div>
      </Container>
    </div>
  );
}
