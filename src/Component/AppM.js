
exports._getAllDocs = coll => () => {
    return coll.find().sort({ updated: -1}).exec();
}

exports._insertDoc = coll => topic => () => {
    return coll.insert(topic);
}