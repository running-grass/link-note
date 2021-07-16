// import IPFS from "ipfs";
// import OrbitDB from 'orbit-db';

const IPFS = require('ipfs');
const OrbitDB = require('orbit-db');

exports.getdb = function main(dbname) {
    return async function () {
        const ipfsOptions = {
            repo: './ipfs',
            config: {
                Addresses: {
                    Swarm: [
                        '/dns4/wrtc-star1.par.dwebops.pub/tcp/443/wss/p2p-webrtc-star',
                        '/dns4/wrtc-star2.sjc.dwebops.pub/tcp/443/wss/p2p-webrtc-star',
                        '/ip4/127.0.0.1/tcp/44005',
                        '/ip6/::/tcp/44005'

                    ],

                },
            }
        }
        
        let ipfs;
        if (!window.ipfs || !window.ipfs.isOnline()) {
             ipfs = await IPFS.create(ipfsOptions)
        }

        const orbitdb = await OrbitDB.createInstance(ipfs)
        const db = await orbitdb.keyvalue(dbname);

        window.orbit = orbitdb;
        window.ipfs = ipfs;
        window.db = db;
        console.log(db.address.toString())
    }
}