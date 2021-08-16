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
            note: {
                schema: {
                    version: 0,
                    primaryKey: 'id',
                    type: 'object',
                    properties: {
                        id: {
                            type: 'string'
                        },
                        hostType: {
                            type: 'string'
                            , enum: ["topic", "file"]
                        },
                        hostId: {
                            type: 'string'
                        },
                        heading: {
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
        // }).catch(e => {
        //     alert("请清空一下缓存");
        });
    });
};

exports._getCollection = (db) => dbName => () => {

    // webpack dev环境使用
    const windowProp = 'coll' + dbName;

    const coll = db.collections[dbName];
    if (coll) {
        window[windowProp] = coll;
        return Promise.resolve(coll);
    } else {
        return Promise.reject(dbName + '不存在');
    }
};