import { createStyles } from "@mantine/core";

export default createStyles((theme) => ({
  logo: {
    position: "relative",
    minHeight: 56,
    display: "flex",
    flexDirection: "row",
    alignItems: "center",
  },

  image: {
    width: 32,
    height: 32,
  },

  title: {
    marginLeft: 10,
    color: theme.colorScheme === "dark" ? theme.white : theme.black,
    fontFamily: `Greycliff CF, ${theme.fontFamily}`,
    fontSize: 20,
    lineHeight: 1.2,
    fontWeight: 900,
  },
}));
