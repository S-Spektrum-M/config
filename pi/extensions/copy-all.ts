import { spawn } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ContentBlock = {
	type?: string;
	text?: string;
	mimeType?: string;
	source?: { mediaType?: string };
};

function contentToText(content: string | ContentBlock[]): string {
	if (typeof content === "string") return content;

	return content
		.flatMap((block) => {
			if (block.type === "text" && typeof block.text === "string") return [block.text];
			if (block.type === "image") {
				return [`[Image: ${block.mimeType ?? block.source?.mediaType ?? "unknown type"}]`];
			}
			return [];
		})
		.join("\n");
}

function copyWith(command: string, args: string[], text: string): Promise<void> {
	return new Promise((resolve, reject) => {
		const child = spawn(command, args, { stdio: ["pipe", "ignore", "pipe"] });
		let stderr = "";
		let settled = false;

		const fail = (error: Error) => {
			if (settled) return;
			settled = true;
			reject(error);
		};

		child.once("error", fail);
		child.stderr.on("data", (chunk) => {
			stderr += chunk.toString();
		});
		child.stdin.once("error", fail);
		child.once("close", (code) => {
			if (settled) return;
			settled = true;
			if (code === 0) resolve();
			else reject(new Error(stderr.trim() || `${command} exited with code ${code}`));
		});
		child.stdin.end(text);
	});
}

async function copyToClipboard(text: string): Promise<string> {
	const candidates: Array<[string, string[]]> =
		process.platform === "darwin"
			? [["pbcopy", []]]
			: process.platform === "win32"
				? [["clip", []]]
				: [
						["clip", []],
						["wl-copy", []],
						["xclip", ["-selection", "clipboard"]],
						["xsel", ["--clipboard", "--input"]],
						["clip.exe", []],
					];

	const errors: string[] = [];
	for (const [command, args] of candidates) {
		try {
			await copyWith(command, args, text);
			return command;
		} catch (error) {
			errors.push(`${command}: ${error instanceof Error ? error.message : String(error)}`);
		}
	}

	throw new Error(`No clipboard command succeeded (${errors.join("; ")})`);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("copy-all", {
		description: "Copy all user and assistant messages on the current branch",
		handler: async (_args, ctx) => {
			await ctx.waitForIdle();

			const sections: string[] = [];
			for (const entry of ctx.sessionManager.getBranch()) {
				if (entry.type !== "message") continue;
				if (entry.message.role !== "user" && entry.message.role !== "assistant") continue;

				const text = contentToText(entry.message.content as string | ContentBlock[]).trim();
				if (text.length === 0) continue;
				sections.push(`${entry.message.role === "user" ? "User" : "Assistant"}:\n${text}`);
			}

			if (sections.length === 0) {
				ctx.ui.notify("No user or assistant messages to copy", "warning");
				return;
			}

			const transcript = `${sections.join("\n\n")}\n`;
			try {
				const command = await copyToClipboard(transcript);
				ctx.ui.notify(`Copied ${sections.length} messages with ${command}`, "info");
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
			}
		},
	});
}
