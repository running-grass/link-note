const toUri = require('multiaddr-to-uri')

exports.addPasteListenner = (ipfs) => (callback) => () => {
    // window.addEventListener('paste', ... or
    console.log(ipfs);
    document.onpaste = function (event) {
        var items = (event.clipboardData || event.originalEvent.clipboardData).items;
        console.log(JSON.stringify(items)); // will give you the mime types
        for (index in items) {
            var item = items[index];
            if (item.kind === 'file') {
                event.preventDefault();
                var blob = item.getAsFile();

                ipfs.add(blob).then(obj => callback(obj.path)()).then(console.log);
            }
        }
    }

    console.debug('已经绑定了粘贴事件');
}

exports.getGatewayUri = (ipfs) => () => {
    return ipfs.config.get("Addresses.Gateway").then(gateway => gateway ? gateway : Promise.reject("没有获取到网关值")).then(toUri);
}

exports.doBlur = (target) => () => {
    target.blur();
}
exports.innerText = (target) => () => {
    console.log('newText', target.innerText)
    return target.innerText || '';
}

exports.insertText = (text) => () => {
    return document.execCommand("insertText", false, text);
}