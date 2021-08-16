const {
    getRxStoragePouch,
    createRxDatabase,
    addPouchPlugin,
} = require('rxdb');
const pouchdbAdapterIdb = require('pouchdb-adapter-idb');

const notMig = doc => doc;

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
            topic: {
                schema: {
                    version: 1,
                    primaryKey: 'id',
                    title: '笔记主题',
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string'
                        },
                        name: {
                            type: 'string'
                        },
                        created: {
                            type: 'integer'
                        },
                        updated: {
                            type: 'integer'
                        },
                        noteIds: {
                            type: 'array',
                            uniqueItems: true,
                            items: {
                                type: "string",
                            }
                        },
                    },
                    required: ['id'],
                    indexes: [
                        'name',
                        'updated', 
                        'created',
                    ]
                },
                migrationStrategies: {
                    1: notMig,
                }, // (optional)
                autoMigrate: true, // (optional)
            },
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
                        created: {
                            type: 'integer'
                        },
                        updated: {
                            type: 'integer'
                        },
                        childrenIds: {
                            type: 'array',
                            uniqueItems: true,
                            items: {
                                type: "string",
                            }
                        },
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
                        },
                        created: {
                            type: 'integer'
                        },
                        updated: {
                            type: 'integer'
                        },
                        childrenIds: {
                            type: 'array',
                            uniqueItems: true,
                            items: {
                                type: "string",
                            }
                        },
                    },
                }
            }
        }).then(() => {
            return db;
        }).catch(e => {
            debugger
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


exports.getTopicCollection = (db) => () => {

    if (window.collTopic) {
        return Promise.resolve(window.collTopic);
    }

    if (db.collections.topic) {
        window.collTopic = db.collections.topic;
        return Promise.resolve(window.collTopic);
    } else {
        return Promise.reject('topic collection not exist！');
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
