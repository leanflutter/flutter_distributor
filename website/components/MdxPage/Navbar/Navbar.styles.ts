import { createStyles } from "@mantine/core";
import { BREAKPOINT } from "../settings";

export default createStyles((theme) => ({
  navbar: {
    position: "fixed",
    backgroundColor:
      theme.colorScheme === "dark" ? theme.colors.dark[6] : theme.white,
    paddingBottom: 0,

    [`@media (max-width: ${BREAKPOINT}px)`]: {
      display: "none",
    },
  },

  links: {
  },

  linksInner: {
    paddingTop: theme.spacing.md,
    paddingBottom: theme.spacing.md,
  },
}));
