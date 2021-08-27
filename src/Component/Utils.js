exports.logAny = a => {
    console.log(a);
    return a;
}


// exports._liftMaybeToPromise = fromMaybe => maybe => () => {
//     const val = fromMaybe(null)(maybe);
//     if (val !== null) {
//         return Promise.resolve(val);
//     } else {
//         return Promise.reject(new Error("需要增加catch"));
//     }
// }

exports._maybeToEffect = fromMaybe => maybe => () => {
    const val = fromMaybe(null)(maybe);
    if (val !== null) {
        return val;
    } else {
        throw new Error('Maybe没有数据');
    }
}

exports._swapElem = just => nothing => idx1 => idx2 => arr => {
    if (idx1 >= arr.length || idx2 >= arr.length || idx1 < 0 || idx2 < 0) {
        return nothing;
    }

    if (idx1 === idx2) {
        return just(arr);
    }

    const newArr = Array.from(arr);
    const temp  = newArr[idx1];
    newArr[idx1] = newArr[idx2];
    newArr[idx2] = temp;

    return just(newArr);
}

exports.refreshWindow = () => {
    location.href = "";
}