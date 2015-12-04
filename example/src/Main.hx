package ;

import flash.display.Graphics;
import flash.display.Shape;
import org.alivepdf.images.ColorSpace;
import flash.utils.CompressionAlgorithm;
import pako.Pako;
import haxe.io.UInt8Array;
import org.alivepdf.layout.Position;
import org.alivepdf.layout.Mode;
import org.alivepdf.layout.Resize;
import openfl.display.Bitmap;
import flash.geom.Rectangle;
import org.alivepdf.colors.RGBColor;
import org.alivepdf.colors.IColor;
import haxe.io.Bytes;
import flash.utils.Endian;
import openfl.Assets;
import flash.utils.ByteArray;
import org.alivepdf.fonts.CodePage;
import org.alivepdf.fonts.EmbeddedFont;
import flash.net.URLRequest;
import org.alivepdf.saving.Method;
import org.alivepdf.pages.Page;
import flash.display.Sprite;
import org.alivepdf.pdf.PDF;

using pako.ByteArrayHelper;

class Main extends Sprite {
    public function new() {
        super();

        var stitchFont = new EmbeddedFont(
            getByteArrayFromResource("assets/Stich-1.ttf"),
            getByteArrayFromResource("assets/Stich-1.afm"),
            CodePage.CP1251);

        var pdf: PDF = new PDF();
        pdf.addPage();
        pdf.setFont(stitchFont, 24);
        pdf.addText("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM[]{}-_|/!@#$%^&*()+=`~.?:,;", 10, 10);
        pdf.addText("q", 100, 100);

        drawCross(pdf, new RGBColor(0x00ff00), 40, 40, 10, 10);

        drawRectangle(pdf, new RGBColor(0x0000ff), 55, 55, 15, 15);

        var shape: Shape = new Shape();
        var g: Graphics = shape.graphics;
        g.beginFill(0x666666);
        g.drawCircle(20, 20, 20);
        g.endFill();

        pdf.addImage(shape, new Resize(Mode.NONE, Position.CENTERED), 100, 150, 100, 100);

        pdf.addImageStream(getByteArrayFromResource("assets/memory.png"), ColorSpace.DEVICE_RGB, new Resize(Mode.NONE, Position.CENTERED), 200, 150, 50, 50);


        var base64: String = pdf.save(Method.BASE_64);

        flash.Lib.getURL(new URLRequest("data:application/pdf;base64," + StringTools.urlEncode(base64)));

        trace(base64.length);

//        var ba = ByteArray.fromBytes(Bytes.ofString("Hello world!"));
//        var compressed = ba.compressEx(CompressionAlgorithm.DEFLATE);
//        trace(compressed);
    }

    private function getByteArrayFromResource(resourceName: String): ByteArray {
        var data = Assets.getBytes(resourceName);
        data.endian = Endian.BIG_ENDIAN;
        return data;
    }

    private function drawCross(p: PDF, color: IColor, x: Float, y: Float, width: Float, height: Float) {
        p.lineStyle(color, width/2);
        p.moveTo(x, y);
        p.lineTo(x + width, y + height);
        p.moveTo(x + width, y);
        p.lineTo(x, y + height);
        p.end();
    }

    private function drawRectangle(p: PDF, color: IColor, x: Float, y: Float, width: Float, height: Float) {
        p.beginFill(color);
        p.drawRect(new Rectangle(x, y, width, height));
        p.endFill();
    }
}
