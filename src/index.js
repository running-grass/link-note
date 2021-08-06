const Main = require('./Main.purs')
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
window.Main = Main;

window.Main.main();

if (module.hot) {
  module.hot.accept();
}

console.log('app starting');
