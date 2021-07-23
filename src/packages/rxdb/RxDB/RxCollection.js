const { isRxCollection } = require('rxdb');

exports.getCollection = db => collName => () => db[collName]
    ? Promise.resolve(db[collName])
    : Promise.reject(`RxCollection【${collName}】不存在`);

exports.isRxCollection = coll => () => isRxCollection(coll);

const withCollection = (coll, callback) => isRxCollection(coll)
    ? callback()
    : Promise.reject("集合不存在！");

exports.insert = coll => json => () => withCollection(coll, () => coll.insert(json));