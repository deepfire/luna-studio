require('react');
require('react-dom');
require('./atom-callback.js');
require('./luna-visualizers.js');
require('./lexer-classes.js');
// PRE-BROWSERIFIED

window.visualizerFramesManager = require('./visualizers');

analytics = {
    track: function (x) {
        console.warn("track: %s", x);
    }
};

function b64ToUint6 (nChr) {
  return nChr > 64 && nChr < 91 ?
      nChr - 65
    : nChr > 96 && nChr < 123 ?
      nChr - 71
    : nChr > 47 && nChr < 58 ?
      nChr + 4
    : nChr === 43 ?
      62
    : nChr === 47 ?
      63
    :
      0;
}

function base64DecToArr (sBase64, nBlockSize) {

  var
    sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""), nInLen = sB64Enc.length,
    nOutLen = nBlockSize ? Math.ceil((nInLen * 3 + 1 >>> 2) / nBlockSize) * nBlockSize : nInLen * 3 + 1 >>> 2, aBytes = new Uint8Array(nOutLen);

  for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
    nMod4 = nInIdx & 3;
    nUint24 |= b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 18 - 6 * nMod4;
    if (nMod4 === 3 || nInLen - nInIdx === 1) {
      for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
        aBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
      }
      nUint24 = 0;
    }
  }

  return aBytes;
}

let buf = base64DecToArr(zipfs).buffer;
console.log("buf: %s", buf);

BrowserFS.install(window);
BrowserFS.configure({
    fs: "ZipFS",
    options: {
        zipData: Buffer.from(buf)
    }
}, function(e) {
    if (e) {
        console.error(e);
        throw e;
    } else
        console.log("BrowserFS initialized.");
});
// var fs = require('fs');
// fs.writeFile('/test.txt', 'Cool, I can do this in the browser!', function(err) {
//     fs.readFile('/test.txt', function(err, contents) {
//         if (err)
//             console.error(err);
//         else
//             console.log(contents.toString());
//     });
// });
