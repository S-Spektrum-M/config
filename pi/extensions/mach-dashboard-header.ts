import { VERSION, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function centerGap(leftText: string, rightText: string, width: number, gapWidth: number): string {
	const gap = Math.min(gapWidth, width);
	const leftWidth = Math.floor((width - gap) / 2);
	const rightWidth = width - gap - leftWidth;
	const left = truncateToWidth(leftText, leftWidth, "");
	const right = truncateToWidth(rightText, rightWidth, "");

	return (
		" ".repeat(leftWidth - visibleWidth(left)) +
		left +
		" ".repeat(gap) +
		right +
		" ".repeat(rightWidth - visibleWidth(right))
	);
}

// Adapted from nvim/lua/mach/user-plugin-opts.lua. The Mach and Neovim
// version labels are replaced with the running pi version.
const BANNER = [
	"                        █▀▄▀█ ▄▀█ █▀▀ █░█                        ",
	"                 .      █░▀░█ █▀█ █▄▄ █▀█      .                 ",
	"                //                             \\\\                ",
	"               //                               \\\\               ",
	`              //${centerGap("pi", VERSION, 33, 3)}\\\\              `,
	"             //                _._                \\\\             ",
	"          .---.              .//|\\\\.              .---.          ",
	"________ / .-. \\_________..-~ _.-._ ~-..________ / .-. \\_________",
	"         \\ ._. /    H-     '--.___.--'     -H    \\ ._. /         ",
	"          •---•     H          [H]          H     •---•          ",
	"                   _H_         _H_         _H_                   ",
	"                   UUU         UUU         UUU                   ",
] as const;

const BANNER_WIDTH = Math.max(...BANNER.map(visibleWidth));

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setHeader((_tui, theme) => ({
			render(width: number): string[] {
				if (width <= 0) return [];

				const leftPadding = " ".repeat(Math.max(0, Math.floor((width - BANNER_WIDTH) / 2)));
				return BANNER.map((line) =>
					theme.fg("accent", truncateToWidth(leftPadding + line, width, "")),
				);
			},
			invalidate() {},
		}));
	});
}
