package pako;

import haxe.io.Bytes;
import haxe.io.UInt8Array;
import flash.utils.CompressionAlgorithm;
import flash.utils.ByteArray;

class ByteArrayHelper {
    public static function compressEx(ba: ByteArray, ?algorithm : CompressionAlgorithm): ByteArray {
        if (null == algorithm) {
            algorithm = CompressionAlgorithm.ZLIB;
        }

        #if js
            var compressed: UInt8Array =
                switch (algorithm) {
                    case CompressionAlgorithm.ZLIB: pako.Pako.gzip(cast cast(ba, Bytes).getData());
                    case CompressionAlgorithm.DEFLATE: pako.Pako.deflate(cast cast(ba, Bytes).getData());
                    case CompressionAlgorithm.LZMA: null;
                    case _: null;
                };
            return if (null != compressed) ByteArray.fromBytes(compressed.view.buffer) else null;
        #else
            ba.compress(algorithm);
            return ba;
        #end
    }
}
