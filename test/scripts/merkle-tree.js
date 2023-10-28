const { Command } = require('commander');
const program = new Command();

program
  .name('merkle-tree')
  .description('CLI to Create MerkleTrees and Get Proofs');

program.command('tree')
  .description('Generate a merkle tree from an array of unhashed values')
  .argument('<string>', 'array of unhashed leaves')
.option('-e, --encoding <string>', 'encoding of unhashed leaves')
  .action((array, options) => {
    console.log(array);
  });


program.command('root')
  .description('Returns the root of merkle tree')
  .argument('<string>', 'array of the elements of a merkle tree')
  .action((array) => {
    console.log(array);
  });

program.command('proof')
  .description('Returns the root of merkle tree')
  .argument('<string>', 'array of the elements of a merkle tree')

.option('-l, --leaf <string>', 'index of the leaf to prove')
  .action((array, options) => {
    console.log(array);
  });

program.command('multiProof')
  .description('Returns the root of merkle tree')
  .argument('<string>', 'array of the elements of a merkle tree')

.option('-l, --leaves <string>', 'indexes of leaves to prove')
  .action((array, options) => {
    console.log(array);
  });
program.parse();
