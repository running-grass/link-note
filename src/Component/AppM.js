exports._getAllDocs = coll => () => {
    return coll.find().sort({ updated: -1}).exec();
}

exports._getDoc = just => nothing => coll => id => () => {
    if (!id) {
        return Promise.resolve(nothing);
    }
    return coll.findOne(id).exec().then(doc => {
        if (doc) {
            return just(doc);
        } else {
            return nothing;
        }
    }).catch(() => Promise.resolve(nothing));
}

exports._insertDoc = coll => topic => () => {
    return coll.insert(topic);
}