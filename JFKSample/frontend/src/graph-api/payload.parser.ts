import { GraphPayload } from "./payload.model";

/**
 * Parsers for Payload.
 * Very simple so far, segregated just in case query got more
 * complex in the future.
 * Example:
 * Input: {search: "oswald"}
 * Output: "q=oswald"
 */

export const parsePayload = (p: GraphPayload): string => {
  return [
    p.search ? `q=${p.search}&f=entities` : "",
    p.search ? `q=${p.search}&f=Section` : "",
    p.search ? `q=${p.search}&f=Author` : "",
    p.search ? `q=${p.search}&f=Point_of_Contact` : ""
  ]
    .filter(i => i)
    .join("&");
};
