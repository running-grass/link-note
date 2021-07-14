exports.write = function(html) {
    return function() {
        document.writeln(html);
    }
} 

// exports.add1 = function(x) { return x + 1;}