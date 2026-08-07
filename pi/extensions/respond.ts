import { spawn } from "node:child_process";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Key, Text } from "@earendil-works/pi-tui";

type EditorResult =
	| { status: "complete"; content: string }
	| { status: "failed"; message: string };

function lastAssistantText(ctx: ExtensionContext): string | undefined {
	const branch = ctx.sessionManager.getBranch();

	for (let index = branch.length - 1; index >= 0; index--) {
		const entry = branch[index];
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;

		const text = entry.message.content
			.filter((block): block is { type: "text"; text: string } => block.type === "text")
			.map((block) => block.text)
			.join("\n");
		if (text.length > 0) return text;
	}

	return undefined;
}

async function editResponse(editor: string, content: string): Promise<EditorResult> {
	const directory = await mkdtemp(join(tmpdir(), "pi-respond-"));
	const filePath = join(directory, "response.md");

	try {
		await writeFile(filePath, content, "utf8");

		const exitCode = await new Promise<number | null>((resolve) => {
			const child = spawn("/bin/sh", ["-c", 'exec $EDITOR "$1"', "pi-respond", filePath], {
				env: { ...process.env, EDITOR: editor },
				stdio: "inherit",
			});
			let settled = false;
			const finish = (code: number | null) => {
				if (settled) return;
				settled = true;
				resolve(code);
			};

			child.once("error", () => finish(null));
			child.once("close", finish);
		});

		if (exitCode !== 0) {
			return {
				status: "failed",
				message: exitCode === null ? `Could not launch ${editor}` : `${editor} exited with code ${exitCode}`,
			};
		}

		const edited = await readFile(filePath, "utf8");
		return { status: "complete", content: edited.replace(/\n$/, "") };
	} finally {
		await rm(directory, { recursive: true, force: true });
	}
}

async function respond(ctx: ExtensionContext): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify("respond requires interactive mode", "error");
		return;
	}
	if (!ctx.isIdle()) {
		ctx.ui.notify("Wait for the current response to finish", "warning");
		return;
	}

	const editor = process.env.EDITOR?.trim();
	if (!editor) {
		ctx.ui.notify("$EDITOR is not set", "error");
		return;
	}

	const response = lastAssistantText(ctx);
	if (!response) {
		ctx.ui.notify("No assistant response found", "warning");
		return;
	}

	const result = await ctx.ui.custom<EditorResult>((tui, theme, _keybindings, done) => {
		queueMicrotask(async () => {
			tui.stop();
			let editorResult: EditorResult;
			try {
				editorResult = await editResponse(editor, response);
			} catch (error) {
				editorResult = {
					status: "failed",
					message: error instanceof Error ? error.message : String(error),
				};
			} finally {
				tui.start();
				tui.requestRender(true);
			}
			done(editorResult);
		});

		return new Text(theme.fg("muted", `Opening last response in ${editor}…`), 1, 1);
	});

	if (result.status === "failed") {
		ctx.ui.notify(result.message, "error");
		return;
	}

	ctx.ui.setEditorText(result.content);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("respond", {
		description: "Edit the last assistant response in $EDITOR",
		handler: async (_args, ctx) => {
			await ctx.waitForIdle();
			await respond(ctx);
		},
	});

	pi.registerShortcut(Key.alt("r"), {
		description: "Edit the last assistant response in $EDITOR",
		handler: respond,
	});
}
