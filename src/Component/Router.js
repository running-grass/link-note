
const { getIpfs, providers } = require('ipfs-provider');
const { httpClient, jsIpfs, windowIpfs } = providers;

const ipfsCore = require('ipfs-core');

const ipfsHttpClient = require('ipfs-http-client');

exports.getGlobalIPFS = (addr) => () => {
    let provider = null;
    switch (addr) {
        case 'none':
            break;
        case 'js':
            provider = jsIpfs();
            break;
        case 'window':
            provider = windowIpfs();
            break;
        default:
            provider = httpClient({ apiAddress: addr });
    }
    if (!provider) {
        return Promise.reject("无IPFS");
    }
    return getIpfs({
        loadHttpClientModule: function () { return ipfsHttpClient.create },
        loadJsIpfsModule: function () { return ipfsCore },
        providers: [
            provider,
        ]
    }).then(({ ipfs, provider, apiAddress }) => {
        window.ipfs = ipfs;

        console.log('IPFS API is provided by: ' + provider)
        if (provider === 'httpClient') {
            console.log('HTTP API address: ' + apiAddress)
        }

        return ipfs;
    })
}
