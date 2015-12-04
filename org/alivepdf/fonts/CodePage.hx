package org.alivepdf.fonts;


import openfl.Assets;
import flash.utils.ByteArray;

@:final class CodePage
{
    public static var CP1250(get, null) : ByteArray;
    private static function get_CP1250(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1250.map"); }

    public static var CP1251(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1251.map");
    private static function get_CP1251(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1251.map"); }

    public static var CP1252(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1252.map");
    private static function get_CP1252(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1252.map"); }

    public static var CP1253(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1253.map");
    private static function get_CP1253(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1253.map"); }

    public static var CP1254(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1254.map");
    private static function get_CP1254(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1254.map"); }

    public static var CP1255(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1255.map");
    private static function get_CP1255(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1255.map"); }

    public static var CP1257(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1257.map");
    private static function get_CP1257(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1257.map"); }

    public static var CP1258(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/cp1258.map");
    private static function get_CP1258(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/cp1258.map"); }

    public static var KOI8U(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/koi8-u.map");
    private static function get_KOI8U(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/koi8-u.map"); }

    public static var KOI8R(get, null) : ByteArray = Assets.getBytes("org/alivepdf/fonts/map/koi8-r.map");
    private static function get_KOI8R(): ByteArray { return Assets.getBytes("org/alivepdf/fonts/map/koi8-r.map"); }
}
