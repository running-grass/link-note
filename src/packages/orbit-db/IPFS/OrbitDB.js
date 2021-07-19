const OrbitDB = require('orbit-db');


exports.createInstance = function(ipfs) {
    return function(options) {
        return async function() {
            return OrbitDB.createInstance(ipfs, options);
        }
    }
}