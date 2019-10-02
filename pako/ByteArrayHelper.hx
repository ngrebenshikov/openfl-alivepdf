package pako;

import openfl.utils.Endian;
import openfl.utils.CompressionAlgorithm;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.UInt8Array;


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

        #elseif cpp
            switch(algorithm) {
                case CompressionAlgorithm.ZLIB: ba.compress(algorithm);
                case CompressionAlgorithm.DEFLATE: ba = ByteArray.fromBytes(local.zip.Compress.run(cast(ba, Bytes), 8));
                case CompressionAlgorithm.LZMA: ba.compress(algorithm);
            }
            return ba;
        #else
            ba.compress(algorithm);
            var res = new ByteArray(ba.length + 6);
            res.endian = Endian.BIG_ENDIAN;
            res.writeByte(0x78);
            res.writeByte(0xda);
            res.writeBytes(ba);
            res.writeInt(haxe.crypto.Adler32.make(ba));
            return res;
        #end
    }
}
