
const {
    getRxStoragePouch,
    createRxDatabase,
    addPouchPlugin
} = require('rxdb');

const pouchdbAdapterIdb = require('pouchdb-adapter-idb');

exports.logAny = a => () => {
    console.log(a);
}

exports.initRxDB = () => () => {
    addPouchPlugin(pouchdbAdapterIdb);
    return createRxDatabase({
        name: 'sis',
        storage: getRxStoragePouch('idb'),
        password: 'myPassword', 
        multiInstance: false,
        eventReduce: false,
    }).then(db => {
        window.db = db;
        return db;
    });
};
exports.getNotesCollection = (db) => () => {
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
                // primaryKey is always required
                required: ['nodeId']
            }
        }
    }).then(colls => {
        window.notes = colls.notes;
        return colls;
    });
};