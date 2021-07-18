const IPFS = require('ipfs');


// exports._create = function() {}

exports.getIpfs = function() {
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
        if (window.ipfs && window.ipfs.isOnline()) {
            ipfs = window.ipfs;
        } else {
            ipfs = await IPFS.create(ipfsOptions)
        }
        
        window.ipfs = ipfs;
        return ipfs;
    }
}

