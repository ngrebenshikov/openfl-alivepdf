# openfl-alivepdf
The PDF generation library ported from the [AlivePDF](http://alivepdf.bytearray.org) AS3 project (ported the [FPDF](http://www.fpdf.org) PHP project)

[AlivePDF API](http://alivepdf.bytearray.org/alivepdf-asdoc/)

It's converted from AS3 to Haxe using [as3hx](https://github.com/HaxeFoundation/as3hx). So there are a lot of issues now. If you'd like to use such library your contribution to check and fix features is completely appreciated.

## Features (Roadmap)

Features are public methods of the org.alive.PDF class.

✓ means a feature's checked, fixed and works OK.

Feature | HTML5 | Native
--- | --- | ---
setMargins |  |
resetMargins |  |
getMargins |  |
setLeftMargin |  |
setTopMargin |  |
setBottomMargin |  |
setRightMargin |  |
setAutoPageBreak |  |
setDisplayMode |  |
setAdvanceTiming |  |
setTitle |  |
setSubject |  |
setAuthor |  |
setKeywords |  |
setCreator |  |
setAliasNbPages |  |
rotatePage |  |
addPage | ✓ |
getPage |  |
getPages |  |
gotoPage |  |
removePage |  |
removeAllPages |  |
getCurrentPage |  |
totalPages |  |
newLine |  |
getX |  |
getY |  |
setX |  |
setY |  |
setXY |  |
getDefaultSize |  |
getDefaultOrientation |  |
getDefaultUnit |  |
skew |  |
rotate |  |
header |  |
footer |  |
setAlpha |  |
moveTo | ✓ |
lineTo | ✓ |
end | ✓ |
drawLine |  |
curveTo |  |
lineStyle | ✓ |
setStrokeColor |  |
setTextColor |  |
beginFill | ✓ |
beginBitmapFill |  |
endFill | ✓ |
drawRect | ✓ |
drawRoundRect |  |
drawRoundRectComplex |  |
drawEllipse |  |
drawCircle | ✓ |
drawPolygone |  |
drawSector |  |
linearGradient |  |
radialGradient |  |
clip |  |
clippingText |  |
clippingRect |  |
clippingRoundedRect |  |
clippingEllipse |  |
clippingCircle |  |
clippingPolygon |  |
unsetClipping |  |
clippedCell |  |
addCodaBar |  |
setVisible |  |
addAnnotation |  |
addBookmark |  |
addLink |  |
getCurrentInternalLink |  |
addTransition |  |
setViewerPreferences |  |
setStartingPage |  |
setFont (TTF) | ✓ |
setFont (Type1) |  |
setFont (System) |  |
setFontSize | ✓ |
removeFont |  |
totalFonts |  |
getFonts |  |
addText | ✓ |
textStyle |  |
addCell |  |
addCellFitScale |  |
addCellFitScaleForce |  |
addCellFitSpace |  |
addCellFitSpaceForce |  |
addMultiCell |  |
writeText |  |
writeFlashHtmlText |  |
addGrid |  |
setGridPositionOnNextPages |  |
save (LOCAL) | ✓ |
save (BASE64) | ✓ |
save (REMOTE) |  |
addJavaScript |  |
addEPSImage |  |
addImageStream (PNG) | ✓ |
addImageStream (JPEG) |  |
addImageStream (GIF) |  |
addImage (PNG) | ✓ |
addImage (JPEG) |  |
addImage (TIFF) |  |
