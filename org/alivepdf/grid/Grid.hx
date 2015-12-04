package org.alivepdf.grid;

import org.alivepdf.grid.GridCell;
import org.alivepdf.grid.GridColumn;

import flash.utils.ByteArray;

import org.alivepdf.colors.IColor;
import org.alivepdf.colors.RGBColor;
import org.alivepdf.export.CSVExport;
import org.alivepdf.export.Export;
import org.alivepdf.serializer.ISerializer;

class Grid
{
    public var columns(get, set) : Array<Dynamic>;
    public var cells(get, never) : Array<Dynamic>;
    public var width(get, never) : Float;
    public var height(get, never) : Float;
    public var rowHeight(get, never) : Int;
    public var headerHeight(get, never) : Int;
    public var x(get, set) : Int;
    public var y(get, set) : Int;
    public var borderColor(get, never) : IColor;
    public var borderAlpha(get, never) : Float;
    public var joints(get, never) : String;
    public var headerColor(get, never) : IColor;
    public var cellColor(get, never) : IColor;
    public var useAlternativeRowColor(get, never) : Bool;
    public var alternativeCellColor(get, never) : IColor;
    public var dataProvider(get, never) : Array<Dynamic>;

    private var _data : Array<Dynamic>;
    private var _width : Float;
    private var _height : Float;
    private var _headerHeight : Int = 0;
    private var _rowHeight : Int = 0;
    private var _x : Int = 0;
    private var _y : Int = 0;
    private var _columns : Array<Dynamic>;
    private var _cells : Array<Dynamic>;  // array of array of GridCell  
    private var _borderColor : IColor;
    private var _borderAlpha : Float;
    private var _joints : String;
    private var _backgroundColor : IColor;
    private var _headerColor : IColor;
    private var _cellColor : IColor;
    private var _alternativeCellColor : IColor;
    private var _useAlternativeRowColor : Bool;
    private var _serializer : ISerializer;
    
    public function new(data : Array<Dynamic>, width : Float, height : Float, headerColor : IColor, cellColor : IColor = null,
            useAlternativeRowColor : Bool = false, alternativeCellColor : IColor = null,
            borderColor : IColor = null, borderAlpha : Float = 1,
            headerHeight : Int = 5, rowHeight : Int = 5,
            joints : String = "0 j", columns : Array<Dynamic> = null)
    {
        _data = data;
        _width = width;
        _height = height;
        _borderColor = ((borderColor == null)) ? new RGBColor(0x000000) : borderColor;  // black by default  
        _borderAlpha = borderAlpha;
        _rowHeight = rowHeight;
        _headerHeight = headerHeight;
        _joints = joints;
        _headerColor = headerColor;
        _cellColor = cellColor = ((cellColor == null)) ? new RGBColor(0xffffff) : cellColor;
        _alternativeCellColor = ((alternativeCellColor == null)) ? new RGBColor(0xd3d3d3) : alternativeCellColor;
        _useAlternativeRowColor = useAlternativeRowColor;
        if (columns != null) 
            this.columns = columns;
    }
    
    public function export(type : String = "csv") : ByteArray
    {
        if (type == Export.CSV) 
            _serializer = new CSVExport(_data, _columns);
        return _serializer.serialize();
    }
    
    
    public function generateColumns(force : Bool = false, headerAlign : String = "L", cellAlign : String = "L") : Void
    {
        var buffer : Array<Dynamic> = dataProvider;
        if ((columns != null && force) || columns == null) 
        {
            var firstItem : Dynamic = buffer[0];
            var fields : Array<String> = new Array<String>();
            var column : GridColumn;
            for (p in Reflect.fields(firstItem))
                fields.push(p);
            fields.sort(function(x, y) {
                return if (x < y) -1 else if (x > y) 1 else 0;
            });
            columns = new Array<Dynamic>();
            var fieldsLng : Int = fields.length;
            for (i in 0...fieldsLng){columns.push(new GridColumn(fields[i], fields[i], Std.int(this.width / fieldsLng), headerAlign, cellAlign));
            }
        }
    }
    
    public function generateCells() : Void
    {
        var buffer : Array<Dynamic> = dataProvider;
        var lng : Int = buffer.length;
        var lngColumns : Int = columns.length;
        var row : Array<Dynamic>;
        var item : Dynamic;
        var isEven : Int = 0;
        var result : Array<Dynamic> = new Array<Dynamic>();
        
        for (i in 0...lng){
            item = buffer[i];
            row = new Array<Dynamic>();
            for (j in 0...lngColumns){
                var cell : GridCell = new GridCell(item[columns[j].dataField]);
                cell.backgroundColor = ((useAlternativeRowColor && cast(isEven = i & 1, Bool))) ? alternativeCellColor : cellColor;
                row.push(cell);
            }
            result.push(row);
        }
        
        _cells = result;
    }
    
    
    private function get_columns() : Array<Dynamic>
    {
        return _columns;
    }
    
    private function set_columns(columns : Array<Dynamic>) : Array<Dynamic>
    {
        _columns = columns;
        return columns;
    }
    
    private function get_cells() : Array<Dynamic>
    {
        return _cells;
    }
    
    private function get_width() : Float
    {
        return _width;
    }
    
    private function get_height() : Float
    {
        return _height;
    }
    
    private function get_rowHeight() : Int
    {
        return _rowHeight;
    }
    
    private function get_headerHeight() : Int
    {
        return _headerHeight;
    }
    
    private function get_x() : Int
    {
        return _x;
    }
    
    private function get_y() : Int
    {
        return _y;
    }
    
    private function set_x(x : Int) : Int
    {
        _x = x;
        return x;
    }
    
    private function set_y(y : Int) : Int
    {
        _y = y;
        return y;
    }
    
    private function get_borderColor() : IColor
    {
        return _borderColor;
    }
    
    private function get_borderAlpha() : Float
    {
        return _borderAlpha;
    }
    
    private function get_joints() : String
    {
        return _joints;
    }
    
    private function get_headerColor() : IColor
    {
        return _headerColor;
    }
    
    private function get_cellColor() : IColor
    {
        return _cellColor;
    }
    
    private function get_useAlternativeRowColor() : Bool
    {
        return _useAlternativeRowColor;
    }
    
    private function get_alternativeCellColor() : IColor
    {
        return _alternativeCellColor;
    }
    
    private function get_dataProvider() : Array<Dynamic>
    {
        return _data;
    }
    
    public function toString() : String
    {
        return "[Grid cells=" + _data.length + " alternateRowColor=" + _useAlternativeRowColor + " x=" + x + " y=" + y + "]";
    }
}
