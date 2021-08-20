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

exports._find = coll => obj => () => {
    return coll.find({selector: obj}).sort({ created: 1}).exec();
}

exports._insertDoc = coll => topic => () => {
    return coll.insert(topic);
}

exports._bulkRemoveDoc = coll => ids => () => {
    return coll.bulkRemove(ids);
}

exports._updateDocById = coll => id => doc => () => {
    return coll.findOne(id).update({ "$set" : doc});
}

exports._getGatewayUri = just => nothing => ipfs => () => {
    return ipfs.config.get("Addresses.Gateway").then(gateway => gateway ? just(toUri(gateway)) : nothing);
}