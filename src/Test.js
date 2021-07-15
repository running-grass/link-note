
const IPFS = require('ipfs')
const OrbitDB = require('orbit-db')


exports.write = function(html) {
    return function() {
        document.writeln(html);
    }
} 


exports.getdb = function main (dbname) {

    return function () {
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
        IPFS.create(ipfsOptions).then(ipfs => {
            OrbitDB.createInstance(ipfs).then(orbitdb => {
                orbitdb.keyvalue(dbname).then(db => {

                    window.orbit = orbitdb;
                    window.ipfs = ipfs;
                    window.db = db;
                    console.log(db.address.toString())
                })
            })

        })
    }
}
// exports.getdb = () => main
// exports.add1 = function(x) { return x + 1;}