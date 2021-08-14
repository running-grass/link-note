
const { getIpfs, providers } = require('ipfs-provider');
const { httpClient, jsIpfs, windowIpfs } = providers;

const ipfsCore = require('ipfs-core');

const ipfsHttpClient = require('ipfs-http-client');

exports.getGlobalIPFS = just => nothing => (addr) => () => {
    let provider = null;
    console.log(addr, 'ipfs');
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
        return Promise.resolve(nothing);
    }
    return getIpfs({
        loadHttpClientModule: function () { return ipfsHttpClient.create },
        loadJsIpfsModule: function () { return ipfsCore },
        providers: [
            provider,
        ]
    }).then((res) => {
        if (!res) return nothing;

        const { ipfs, provider, apiAddress } = res;
        window.ipfs = ipfs;

        console.log('IPFS API is provided by: ' + provider)
        if (provider === 'httpClient') {
            console.log('HTTP API address: ' + apiAddress)
        }

        return just(ipfs);
    })
}
