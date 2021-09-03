const {
    getRxStoragePouch,
    createRxDatabase,
    addPouchPlugin,
} = require('rxdb');
const pouchdbAdapterIdb = require('pouchdb-adapter-idb');
const S = require('sanctuary');
const moment = require('moment');

const notMig = doc => doc;

const collectionScheme = {
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
                    type: 'string',
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
            required: ['id', 'name'],
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
            version: 1,
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
                parentId: {
                    type: 'string'
                },
                childrenIds: {
                    type: 'array',
                    uniqueItems: true,
                    items: {
                        type: "string",
                    }
                },
            },
            indexes: [
                'hostId',
                'updated', 
                'created',
                'parentId',
                // 'childrenIds'
            ]
        },
        migrationStrategies: {
            1: notMig,
        }, // (optional)
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
}

exports.initRxDB = () => () => {
    addPouchPlugin(pouchdbAdapterIdb);
    if (window.db) {
        return Promise.resolve(window.db);
    }
    return createRxDatabase({
        name: 'linknote', // + new Date().getTime(),
        storage: getRxStoragePouch('idb'),
        password: 'linknote',
        multiInstance: true,
        eventReduce: false,
    }).then(db => {
        window.db = db;
        return db;
    });
};

exports._initCollections = db => () => {
    if (S.size(db.collections)) {
        return Promise.resolve(true);
    }
    return db.addCollections(collectionScheme).then(() => {
        return true;
    }).catch(e => {
        console.error(e);
        alert("数据库结构升级，旧数据库结构不再兼容，请至设置页面手动导出已有数据，然后删除数据库，然后就好啦");
        return false;
    });
}

const alertUserKey = "has_been_alert_user_" + moment().format('YYYY-MM-DD');
exports._alertUser = () => {
    if (!localStorage.getItem(alertUserKey)) {
        alert("该软件正处于快速迭代期，数据库结构随时会出现不兼容的变更。所以仅可用于测试使用，不可用来存储有用的数据。")
        localStorage.setItem(alertUserKey, 1);
    }
}