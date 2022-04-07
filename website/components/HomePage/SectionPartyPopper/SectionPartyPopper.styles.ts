import { createStyles } from "@mantine/core";

export default createStyles((theme) => ({
  wrapper: {
    position: "relative",
    minHeight: 220,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor:
      theme.colorScheme === "dark"
        ? theme.colors.dark[8]
        : theme.colors.gray[0],
  },

  body: {
    zIndex: 1,
  },
}));
