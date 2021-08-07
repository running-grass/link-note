const toUri = require('multiaddr-to-uri')

exports.addPasteListenner = (ipfs) => (callback, callbackText) => () => {
    // window.addEventListener('paste', ... or
    console.log(ipfs);
    document.onpaste = function (event) {
        event.preventDefault();
        const clipboardData = (event.clipboardData || event.originalEvent.clipboardData);

        maybeText = clipboardData.getData('text');

        if (maybeText) {
            console.log(maybeText)
            exports.insertText(maybeText)();
            return;
        }
        
        var items = clipboardData.items;
        for (index in items) {

            var item = items[index];
            // window.item = item;
            console.log(item.kind);

            if (item.kind === 'file') {
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

exports.autoFocus  = (id) => () => {
    setTimeout(() => {
        const tar = document.querySelector(`li#${id} textarea`);
        console.log(tar);
        tar.focus();
    })
}

exports.nowTime = () => {
    return Date.now();
}