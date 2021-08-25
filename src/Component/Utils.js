exports.logAny = a => {
    console.log(a);
    return a;
}


exports._liftMaybeToPromise = fromMaybe => maybe => () => {
    const val = fromMaybe(null)(maybe);
    if (val !== null) {
        return Promise.resolve(val);
    } else {
        return Promise.reject(new Error("需要增加catch"));
    }
}