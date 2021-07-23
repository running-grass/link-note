const {
    addPouchPlugin,
    checkAdapter,
} = require('rxdb');

const pouchdbAdapterIdb = require('pouchdb-adapter-idb');

exports.getPouchdbAdapterIdb = () => () => pouchdbAdapterIdb;

exports.addPouchPlugin = pouchPlugin => () => addPouchPlugin(pouchPlugin);

exports.checkAdapter = adapter => () => checkAdapter(adapter);