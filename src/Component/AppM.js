const download = require('downloadjs');
const moment = require('moment');
exports._getAllDocs = coll => () => {
    return coll.find().sort({ updated: -1}).exec().then(list => list.map(a => a.toJSON()));
}

exports._getDoc = just => nothing => coll => key => val => () => {
    if (!key) {
        return Promise.resolve(nothing);
    }
    return coll.findOne().where(key).eq(val).exec().then(doc => {
        if (doc) {
            return just(doc.toJSON());
        } else {
            return nothing;
        }
    }).catch(() => Promise.resolve(nothing));
}

exports._find = coll => obj => () => {
    return coll.find({selector: obj}).sort({ updated: 1}).exec().then(list => list.map(a => a.toJSON()));
}
// exports._findDocumentsBySelector = coll => obj => () => {
//     return coll.find({selector: obj}).sort({ created: 1}).exec().then(list => list.map(a => a.toJSON()));
// }


exports._insertDoc = just => nothing => coll => topic => () => {
    return coll.insert(topic)
                .then(doc => just(doc))
                .catch(() => nothing);
}

exports._bulkRemoveDoc = coll => ids => () => {
    return coll.bulkRemove(ids);
}

exports._updateDocById = coll => id => doc => () => {
    return coll.upsert(doc);
}

exports._getGatewayUri = just => nothing => ipfs => () => {
    return ipfs.config.get("Addresses.Gateway").then(gateway => gateway ? just(toUri(gateway)) : nothing);
}

exports._log = a => () => {
    console.log(a);
}

exports._deleteDB = db => () => db.remove().then(() => {
    location.href = "";
});

exports._exportDB = db => () => {
    return db.exportJSON().then(json => {
        console.dir(json);
        download(JSON.stringify(json), 'Link-Node备份-' + moment().format("YYYY-MM-DD-hh-mm-ss") + '.json', 'text/json');
    }).then(() => true);
}

