const fs = require('fs');
const argv = require('yargs').argv;

/*
 * 3 args required:
 * --template: which file do we replace in?
 * --find: what string do we search for in the template?
 * --replace: what file do we replace the match with?
*/

const template = fs.readFileSync(argv.template).toString().trim();
//const replace = fs.readFileSync(argv.replace).toString();
let replace = fs.readFileSync('/dev/stdin').toString().trim();

if (argv.surround) {
  replace = argv.surround + replace + argv.surround;
}

const result = template.replace(argv.find, replace);

console.log(result);
//fs.writeFileSync(argv.template, result)
