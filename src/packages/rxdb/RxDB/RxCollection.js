const { isRxCollection } = require('rxdb');

exports.getCollection = db => collName => () => db[collName]
    ? Promise.resolve(db[collName])
    : Promise.reject(new TypeError(`RxCollection【${collName}】不存在`));

exports.isRxCollection = coll => () => isRxCollection(coll);

const withCollection = (coll, callback) => isRxCollection(coll)
    ? callback()
    : Promise.reject(new TypeError("RxCollection类型不正确"));
const withCollectionE = coll => () => {
    if(!isRxCollection(coll)) {
        throw new TypeError("RxCollection类型不正确")
    }
    return callback();
}

exports.insert = coll => json => () => withCollection(coll, () => coll.insert(json));

exports.find = coll => queryObj => () => withCollection(coll, () => coll.find(queryObj))

exports.findOne = coll => queryObj => () => withCollection(coll, () => coll.findOne(queryObj))