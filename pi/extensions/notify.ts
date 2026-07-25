import path from "node:path";
import { fileURLToPath } from "node:url";
import fs from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function getIconPath(): string | undefined {
	try {
		const dir = typeof __dirname !== "undefined"
			? __dirname
			: path.dirname(fileURLToPath(import.meta.url));
		const resolved = path.resolve(dir, "../pi.svg");
		if (fs.existsSync(resolved)) return resolved;
	} catch {
		// Ignore resolution errors
	}
	const homePath = path.join(process.env.HOME || "", ".pi/agent/pi.svg");
	if (fs.existsSync(homePath)) return homePath;

	return undefined;
}

export default function (pi: ExtensionAPI) {
	pi.on("agent_settled", async () => {
		process.stdout.write("\x07");
		const iconPath = getIconPath();
		const args = ["-a", "Pi", "-t", "3000"];
		if (iconPath) {
			args.push("-i", iconPath);
		}
		args.push("Pi", "Ready for input");

		await pi.exec("notify-send", args);
	});
}

