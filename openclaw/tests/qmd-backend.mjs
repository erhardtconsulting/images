import {execFileSync} from "node:child_process";
import {realpathSync} from "node:fs";
import {createRequire} from "node:module";
import {pathToFileURL} from "node:url";

const qmd = realpathSync(execFileSync("which", ["qmd"], {encoding: "utf8"}).trim());
const require = createRequire(qmd);
const {getLlama} = await import(pathToFileURL(require.resolve("node-llama-cpp")).href);
const llama = await getLlama({gpu: false, build: "never", download: false});
await llama.dispose();
