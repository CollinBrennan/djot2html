import fs from "node:fs";
import { Ok, Error } from "./gleam.mjs";

export function read(path) {
  try {
    return new Ok(fs.readFileSync(path, "utf8"));
  } catch (error) {
    return new Error(error.toString());
  }
}
