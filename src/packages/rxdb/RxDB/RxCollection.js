exports.getCollection = db => collName => () => db[collName]
    ? Promise.resolve(db[collName])
    : Promise.reject(`RxCollection【${collName}】不存在`);