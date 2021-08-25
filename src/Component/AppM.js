exports._getAllDocs = coll => () => {
    // return Promise.reject("errrrrrr");
    return coll.find().sort({ updated: -1}).exec().then(list => list.map(a => a.toJSON()));
}

exports._getDoc = just => nothing => coll => id => () => {
    if (!id) {
        return Promise.resolve(nothing);
    }
    return coll.findOne(id).exec().then(doc => {
        if (doc) {
            return just(doc.toJSON());
        } else {
            return nothing;
        }
    }).catch(() => Promise.resolve(nothing));
}

exports._find = coll => obj => () => {
    return coll.find({selector: obj}).sort({ created: 1}).exec().then(list => list.map(a => a.toJSON()));
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

exports._log = a => () => {
    console.log(a);
}