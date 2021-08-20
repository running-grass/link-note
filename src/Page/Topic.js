const toUri = require('multiaddr-to-uri')


exports.addPasteListenner = (fromMaybe) => (maybeIpfs) => (callback, callbackText) => () => {
    // window.addEventListener('paste', ... or
    const ipfs = fromMaybe(null)(maybeIpfs);

    document.onpaste = function (event) {
        event.preventDefault();
        const clipboardData = (event.clipboardData || event.originalEvent.clipboardData);

        maybeText = clipboardData.getData('text');
        if (maybeText) {
            // console.log(maybeText)
            exports.insertText(maybeText)();
            return;
        }
        
        var items = clipboardData.items;
        for (index in items) {

            var item = items[index];
            // window.item = item;
            console.log(item.kind);

            if (item.kind === 'file') {
                if (!ipfs) {
                    window.alert("您未配置IPFS实例，暂不提供文件服务！");
                    return;
                }
                var blob = item.getAsFile();

                ipfs.add(blob).then(obj => callback(obj.path)()).then(console.log);
            }
        }
    }

    console.debug('已经绑定了粘贴事件');
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
        // console.log(tar);
        tar.focus();
    })
}