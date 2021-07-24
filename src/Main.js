
const {
    getRxStoragePouch,
    createRxDatabase,
    addPouchPlugin,
    removeRxDatabase,
} = require('rxdb');

const pouchdbAdapterIdb = require('pouchdb-adapter-idb');
const { async } = require('rxjs');

exports.logAny = a => () => {
    console.log(a);
}


exports.initRxDB = () =>  () => {
    addPouchPlugin(pouchdbAdapterIdb);
    if (window.db) {
        return Promise.resolve(window.db);
    }
    return createRxDatabase({
        name: 'ais' , // + new Date().getTime(),
        storage: getRxStoragePouch('idb'),
        password: 'myPassword', 
        multiInstance: true,
        eventReduce: false,
    }).then(db => {
        window.db = db;
        return db;
    });
};

exports.getNotesCollection = (db) => () => {

    if (window.notes) {
        return Promise.resolve(window.notes);
    }
    return db.addCollections({
        notes: {
            schema: {
                version: 0,
                primaryKey: 'noteId',
                type: 'object',
                properties: {
                    noteId: {
                        type: 'string'
                    },
                    content: {
                        type: 'string'
                    }
                },
            }
        }
    }).then(colls => {
        window.notes = colls.notes;
        return colls.notes;
    });
};