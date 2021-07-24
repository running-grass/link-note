const {
    isRxQuery
} = require('rxdb');

const withQueryP = (query, callback) => isRxQuery(query)
    ? callback()
    : Promise.reject(new TypeError("RxQuery类型不正确"));

exports.isRxQuery = query => () => isRxQuery(query);

exports.exec = query => () => withQueryP(query, () => {
        return query.exec()
});

exports.emptyQueryObject = undefined;

exports.primaryQuery = str => str;