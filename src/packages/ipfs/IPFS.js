const IPFS = require('ipfs');

exports.create = function create(options) {
    return function() {
        return IPFS.create(options);
    }
};

exports.getGlobalIPFS = function getGlobalIPFS() {
    return async function() {
        if (window.ipfs && window.ipfs.isOnline()) {
            return window.ipfs;
        } 
    
        const ipfs = await exports.create(exports.getDefaultIpfsConfig())();
        window.ipfs = ipfs;
        return ipfs;
    };
}

exports.getDefaultIpfsConfig = function() {
    return {
        repo: './ipfs',
        config: {
            Addresses: {
                Swarm: [
                    '/dns4/wrtc-star1.par.dwebops.pub/tcp/443/wss/p2p-webrtc-star',
                    '/dns4/wrtc-star2.sjc.dwebops.pub/tcp/443/wss/p2p-webrtc-star',
                ],

            },
        }
    };
};

exports.version = function version(ipfs) {
    return function() {
        return ipfs.version();
    }
} 