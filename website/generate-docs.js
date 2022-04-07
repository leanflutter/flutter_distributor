const fs = require("fs-extra");
const path = require("path");

const { i18n } = require("./next-i18next.config");

const repoRoot = path.resolve(__dirname, "..");

async function generateDocs() {
  for (let i = 0; i < i18n.locales.length; i++) {
    const locale = i18n.locales[i];

    const src = path.resolve(repoRoot, "docs", locale);
    const dest = path.resolve(__dirname, "_source", locale, "docs");

    fs.emptyDirSync(dest);
    fs.copySync(src, dest);
  }
}

generateDocs()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
