const { spawnSync } = require("child_process");

describe("merkle-tree root command", () => {
	it("should generate a merkle tree and write the root to stdout", () => {
		const inputArray = JSON.stringify(["leaf1", "leaf2", "leaf3"]);
		const encoding = JSON.stringify(["string"]);
		const expectedRoot = "expectedRootValue";

		// Run the merkle-tree CLI command
		const result = spawnSync("node", [
			"merkle-tree.js",
			"root",
			inputArray,
			"--encoding",
			encoding,
		]);

		// Verify that the command executed successfully
		expect(result.status).toBe(0);
		expect(result.error).toBe(undefined);

		// Verify the stdout output
		expect(result.stdout.toString().trim()).toBe(expectedRoot);
	});
});
