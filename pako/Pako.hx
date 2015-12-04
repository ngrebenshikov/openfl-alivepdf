package pako;

import haxe.io.UInt8Array;

@:native('pako')
extern class Pako {
    public static function deflate(data: UInt8Array, ?options: Dynamic): UInt8Array;
    public static function gzip(data: UInt8Array, ?options: Dynamic): UInt8Array;
}
