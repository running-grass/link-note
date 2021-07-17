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
        console.log(db.address.toString())
    };
};