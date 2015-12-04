package org.alivepdf.grid;


@:final class GridColumn
{
    public var headerText(get, never) : String;
    public var dataField(get, never) : String;
    public var width(get, never) : Int;
    public var cellAlign(get, never) : String;
    public var headerAlign(get, never) : String;

    private var _headerText : String;
    private var _dataField : String;
    private var _width : Int = 0;
    
    private var _cellAlign : String;
    private var _headerAlign : String;
    
    public function new(headerText : String, dataField : String, width : Int = 30, headerAlign : String = "L", cellAlign : String = "L")
    {
        _headerText = headerText;
        _dataField = dataField;
        _width = width;
        _headerAlign = headerAlign;
        _cellAlign = cellAlign;
    }
    
    private function get_headerText() : String
    {
        return _headerText;
    }
    
    private function get_dataField() : String
    {
        return _dataField;
    }
    
    private function get_width() : Int
    {
        return _width;
    }
    
    private function get_cellAlign() : String
    {
        return _cellAlign;
    }
    
    private function get_headerAlign() : String
    {
        return _headerAlign;
    }
}
