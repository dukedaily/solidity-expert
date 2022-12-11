"use strict";

var _commander = _interopRequireDefault(require("commander"));
var _fs = require("fs");
var _package = _interopRequireDefault(require("../package.json"));
var _index = _interopRequireDefault(require("./index.js"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }
var extendedHelp = "\n\n".concat(_package["default"].description, "\n\nExample:\n$ cat MyContract.sol | solgraph > MyContract.dot");
var program = _commander["default"].version(_package["default"].version).arguments('<file>').usage(extendedHelp).parse(process.argv);
var input = program.args[0] ?
// filename from command line arguments
new Promise(function (resolve, reject) {
  (0, _fs.readFile)(program.args[0], 'utf-8', function (err, data) {
    if (err) {
      return reject(err);
    }
    resolve(data);
  });
}) :
// stdin
require('get-stdin-promise');
input.then(function (source) {
  console.log((0, _index["default"])(source));
});