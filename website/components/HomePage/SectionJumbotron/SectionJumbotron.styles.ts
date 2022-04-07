import { createStyles } from "@mantine/core";

export default createStyles((theme) => ({
  wrapper: {
    position: "relative",
    minHeight: 420,
  },

  title: {
    color: theme.colorScheme === "dark" ? theme.white : theme.black,
    fontFamily: `Greycliff CF, ${theme.fontFamily}`,
    fontSize: 40,
    lineHeight: 1.2,
    fontWeight: 900,
  },

  highlight: {
    color:
      theme.colorScheme === "dark"
        ? theme.colors.indigo[4]
        : theme.colors.indigo,
  },

  description: {
    color:
      theme.colorScheme === "dark"
        ? theme.colors.dark[1]
        : theme.colors.dark[9],
    fontFamily: `Greycliff CF, ${theme.fontFamily}`,
    lineHeight: 1.5,
    fontSize: 20,
    maxWidth: 520,
    marginTop: theme.spacing.md,
  },

  latestVersion: {
    color:
      theme.colorScheme === "dark"
        ? theme.colors.dark[2]
        : theme.colors.gray[7],
    lineHeight: 1.5,
    fontSize: 14,
    maxWidth: 580,
    marginTop: theme.spacing.md,
  },

  body: {
    flex: "0 0 700px",
    paddingTop: 100,
    position: "relative",
    zIndex: 1,
  },

  image: {
    width: 374,
    height: 184,
    position: "absolute",
    top: 100,
    bottom: 0,
    right: 0,
    zIndex: 0,
    display: theme.dir === "rtl" ? "none" : undefined,
    borderStyle: "solid",
    borderWidth: 1,
    borderColor:
      theme.colorScheme === "dark"
        ? theme.colors.dark[6]
        : theme.colors.gray[4],

    "@media (max-width: 1230px)": {
      display: "none",
    },
  },

  controls: {
    marginTop: theme.spacing.md,
  },

  control: {
    "@media (max-width: 600px)": {
      flex: 1,
    },
  },
}));
