'use strict';

require('babel-polyfill');
const main = require('./Main.purs')
const app = document.querySelector("#halogen-app");
if (app) {
  app.innerHTML = '';
}

main.main();

if (module.hot) {
  module.hot.accept();
}

console.log('app starting');
