const IPFS = require('ipfs')
const OrbitDB = require('orbit-db')

exports.docs = function(orbitdb) {
    return function(dbName) {
        return function(options) {
            return function() {
                return orbitdb.docs(dbName, options).then(function(db) {
                    window.db = db;
                    return db.load().then(function() { return db ;});
                    // return db;
                });
            }
        }
    }
}

exports.put = function(db) {
    return function(doc) {
        return function() {
            return db.put(doc)
        }
    }
}

exports.get = function(db) {
    return function(key) {
        return function() {
            return db.get(key)
        }
    }  
}

exports.query = function(db) {
    return function(mapper) {
        return function() {
            return db.query(mapper);
        }
    }
}

exports.del = function(db) {
    return function(key) {
        return function() {
            return db.del(key);
        }
    }
}