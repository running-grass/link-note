const {
    isRxDocument
} = require('rxdb');

const withDocE = (rxDoc, callback) => {
    if (!isRxDocument(rxDoc)) {
        throw new TypeError('RxDocument类型不正确');
    }
    return callback();
}

exports.isRxDocument = rxDoc => () => isRxDocument(rxDoc);

exports.toJSON = rxDoc => () => withDocE(rxDoc, () => rxDoc.toJSON());