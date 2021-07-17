// import IPFS from "ipfs";
// import OrbitDB from 'orbit-db';

const OrbitDB = require('orbit-db');


exports.getdbByIpfs_ = function main(ipfs, dbname) {
    // return func
    return async function() {
        const ipfs_ = await ipfs;
        const orbitdb = await OrbitDB.createInstance(ipfs_);
        const db = await orbitdb.keyvalue(dbname);

        window.orbit = orbitdb;
        window.db = db;
        db.load();
        console.log(db.address.toString());

        return db;
    };
};

exports.saveVal_ = function(key) {
        return function(val) {
            return function() {
                window.db.put(key, val);
            }
        }
    }

exports.getVal_ = function(key) {
    return function() {
        return window.db.get(key);
    }
}