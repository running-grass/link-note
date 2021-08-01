
const {
    getRxStoragePouch,
    createRxDatabase,
    addPouchPlugin,
} = require('rxdb');

const { getIpfs, providers } = require('ipfs-provider');
const { httpClient, jsIpfs, windowIpfs } = providers;

const pouchdbAdapterIdb = require('pouchdb-adapter-idb');
const ipfsCore = require('ipfs-core');

const ipfsHttpClient = require('ipfs-http-client');
exports.logAny = a => () => {
    console.log(a);
}

exports.getGlobalIPFS = () => {
    return getIpfs({
        loadHttpClientModule: function () { return ipfsHttpClient.create },
        loadJsIpfsModule: function () { return ipfsCore },
        providers: [
            windowIpfs(),
            // httpClient(), // try "/api/v0/" on the same Origin as the page
            httpClient({
                apiAddress: 'http://127.0.0.1:45005'
            }),
            httpClient({
                apiAddress: 'http://127.0.0.1:5001'
            }),
            httpClient({
                apiAddress: 'https://ipfs-api.grass.work:30443/'
            }),
            jsIpfs(),
        ]
    }).then(({ ipfs, provider, apiAddress }) => {
        window.ipfs = ipfs;

        console.log('IPFS API is provided by: ' + provider)
        if (provider === 'httpClient') {
            console.log('HTTP API address: ' + apiAddress)
        }

        return ipfs;
    })
}


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
                    },
                    type: {
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