package org.alivepdf.export;

import flash.errors.Error;

import flash.utils.ByteArray;

import org.alivepdf.grid.GridColumn;
import org.alivepdf.serializer.ISerializer;

@:final class CSVExport implements ISerializer
{
    private var _data : Array<Dynamic>;
    private var _columns : Array<Dynamic>;
    private var buffer : String = "";
    private var output : ByteArray = new ByteArray();
    
    public function new(data : Array<Dynamic>, columns : Array<Dynamic>)
    {
        _data = data;
        _columns = columns;
    }
    
    public function serialize() : ByteArray
    {
        if (_columns == null)             throw new Error("Set the Grid.columns property to use the export feature.");
        
        var line : String;
        var lng : Int = _columns.length;
        var column : GridColumn;
        var field : String;
        var delimiter : String = ";";
        
        for (item in _data)
        {
            line = "";
            for (i in 0...lng){
                column = _columns[i];
                var v = Reflect.field(item, column.dataField);
                field =  v != (null) ? v : "";
                line += line.length > (0) ? delimiter + field : field;
            }
            line += "\n";
            buffer += line;
        }
        output.writeUTFBytes(buffer);
        return output;
    }
}
