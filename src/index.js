'use strict';

require('@babel/polyfill');

// import '@babel/polyfill';

const main = require('./Main.purs')
if (!window) {
  window = {};
}

window.global = window;
window.process = {
    env: { DEBUG: undefined },
};

const app = document.querySelector("#halogen-app");
if (app) {
  app.innerHTML = '';
}
window.main = main;

main.main();

if (module.hot) {
  module.hot.accept();
}

console.log('app starting');
