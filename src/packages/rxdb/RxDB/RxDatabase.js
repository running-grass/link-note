const { isRxDatabase, createRxDatabase } = require('rxdb');

const withRxDdatabase = (db, callback) => isRxDatabase(db)
    ? callback()
    : Promise.reject(new TypeError("数据库类型不正确！"));

exports.isRxDatabase = db => () => isRxDatabase(db);

exports.createRxDatabase = option => () => createRxDatabase(option).then(db => {
    window.rxdb = db;
    return db;
});

exports.addCollections = db => opt => () => withRxDdatabase(db, () => db.addCollections(opt))

exports.exportJSON = db => () => withRxDdatabase(db, () => db.exportJSON());

exports.importJSON = db => json => () => withRxDdatabase(db, () => db.importJSON(json));

exports.destroy = db => () => withRxDdatabase(db, () => db.destroy());

exports.remove = db => () => withRxDdatabase(db, () => db.remove());

exports.requestIdlePromise = db => () => withRxDdatabase(db, () => db.requestIdlePromise());