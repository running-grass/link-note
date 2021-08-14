const {
    getRxStoragePouch,
    createRxDatabase,
    addPouchPlugin,
} = require('rxdb');
const pouchdbAdapterIdb = require('pouchdb-adapter-idb');

exports.initRxDB = () => () => {
    addPouchPlugin(pouchdbAdapterIdb);
    if (window.db) {
        return Promise.resolve(window.db);
    }
    return createRxDatabase({
        name: 'ais', // + new Date().getTime(),
        storage: getRxStoragePouch('idb'),
        password: 'myPassword',
        multiInstance: true,
        eventReduce: false,
    }).then(db => {
        window.db = db;
        return db.addCollections({
            notes: {
                schema: {
                    version: 0,
                    primaryKey: 'id',
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string'
                        },
                        content: {
                            type: 'string'
                        },
                        type: {
                            type: 'string'
                        }
                    },
                }
            },
            file: {
                schema: {
                    version: 0,
                    primaryKey: 'id',
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string'
                        },
                        cid: {
                            type: 'string'
                        },
                        mime: {
                            type: 'string',
                            default: 'unknow'
                        },
                        type: {
                            type: 'string'
                        }
                    },
                }
            }
        }).then(() => {
            return db;
        });
    });
};

exports.getNotesCollection = (db) => () => {

    if (window.notes) {
        return Promise.resolve(window.notes);
    }

    if (db.collections.notes) {
        window.notes = db.collections.notes;
        return Promise.resolve(window.notes);
    } else {
        return Promise.reject('note collection not exist！');
    }
};

exports.getFileCollection = (db) => () => {

    if (window.collFile) {
        return Promise.resolve(window.collFile);
    }

    if (db.collections.file) {
        window.collFile = db.collections.file;
        return Promise.resolve(window.collFile);
    } else {
        return Promise.reject('file collection not exist！');
    }
};
