import { headingRank } from "hast-util-heading-rank";
import { toString } from "hast-util-to-string";
import { visit } from "unist-util-visit";

interface ExtractHeadingsConfig {
  rank: number;
  headings: any[];
}
/**
 * Extracts headings from a unified tree.
 *
 * To be used *AFTER* the `rehype-slug` plugin.
 */
export default function rehypeExtractHeadings({
  rank = 2,
  headings,
}: ExtractHeadingsConfig) {
  return (tree: any) => {
    visit(tree, "element", (node: any) => {
      if (headingRank(node) === rank) {
        headings.push({
          depth: headingRank(node),
          value: toString(node),
        });
      }
    });
  };
}
