import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("agent_settled", async () => {
		process.stdout.write("\x07");
		await pi.exec("notify-send", ["-t", "3000", "Pi", "Ready for input"]);
	});
}
