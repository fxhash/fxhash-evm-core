const { Command } = require("commander");
const program = new Command();

program
	.name("merkle-tree")
	.description("CLI to Create MerkleTrees and Get Proofs");

program
	.command("root")
	.description("Generate a merkle tree from an array of unhashed values")
	.argument("<string>", "array of unhashed leaves")
	.option("-e, --encoding <string>", "encoding of unhashed leaves")
	.action((array, options) => {
		const values = JSON.parse(array);
		const tree = StandardMerkleTree.of(values, JSON.parse(options.encoding));
		process.stdout.write(tree.root);
	});

program
	.command("proof")
	.description("Returns the proofs for an element of a merkle tree")
	.argument("<string>", "array of unhashed leaves")
	.option("-e, --encoding <string>", "encoding of unhashed leaves")
	.option("-i, --index <string>", "index of the leaf to prove")
	.action((array, options) => {
		const values = JSON.parse(array);
		const tree = StandardMerkleTree.of(values, JSON.parse(options.encoding));
		process.stdout.write(tree.getProof(options.index));
	});

program
	.command("multiProof")
	.description("Returns the root of merkle tree")
	.argument("<string>", "array of the elements of a merkle tree")
	.option("-e, --encoding <string>", "encoding of unhashed leaves")
	.option("-i, --indexes <string>", "array of indexes of leaves to prove")
	.action((array, options) => {
		const values = JSON.parse(array);
		const tree = StandardMerkleTree.of(values, JSON.parse(options.encoding));
		process.stdout.write(tree.getMultiProof(JSON.parse(options.indexes)));
	});

program.parse();
