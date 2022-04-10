import React from "react";
import { Navbar as NavbarComp, ScrollArea } from "@mantine/core";
import { Notes } from "tabler-icons-react";
import { LinksGroup } from "./LinksGroup";

import useStyles from "./Navbar.styles";

const mockdata = [
  {
    label: "Getting Started",
    icon: Notes,
    link: "/docs/getting-started"
  },
  {
    label: "Distribute Options",
    icon: Notes,
    link: "/docs/distribute-options"
  },
  {
    label: "CLI",
    icon: Notes,
    link: "/docs/cli"
  },
  {
    label: "Makers",
    icon: Notes,
    links: [
      { label: "aab", link: "/docs/makers/aab" },
      { label: "apk", link: "/docs/makers/apk" },
      { label: "deb", link: "/docs/makers/deb" },
      { label: "dmg", link: "/docs/makers/dmg" },
      { label: "exe", link: "/docs/makers/exe" },
      { label: "ipa", link: "/docs/makers/ipa" },
      { label: "msix", link: "/docs/makers/msix" },
      { label: "zip", link: "/docs/makers/zip" },
    ],
  },
  {
    label: "Publishers",
    icon: Notes,
    links: [
      { label: "appstore", link: "/docs/publishers/appstore" },
      { label: "fir", link: "/docs/publishers/fir" },
      { label: "firebase", link: "/docs/publishers/firebase" },
      { label: "github", link: "/docs/publishers/github" },
      { label: "pgyer", link: "/docs/publishers/pgyer" },
      { label: "qiniu", link: "/docs/publishers/qiniu" },
    ],
  },
  {
    label: "Tools",
    icon: Notes,
    links: [
      { label: "Parse App Package", link: "/docs/tools/parse-app-package" },
    ],
  },
];

export function Navbar() {
  const { classes } = useStyles();
  const links = mockdata.map((item) => (
    <LinksGroup {...item} key={item.label} />
  ));

  return (
    <NavbarComp
      height={800}
      width={{ sm: 260 }}
      className={classes.navbar}
    >
      <NavbarComp.Section grow className={classes.links} component={ScrollArea}>
        <div className={classes.linksInner}>{links}</div>
      </NavbarComp.Section>
    </NavbarComp>
  );
}
