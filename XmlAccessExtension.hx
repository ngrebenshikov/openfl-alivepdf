class XmlAccessExtension {
	public static function descendants(x: FastXML, name:String = "*"): FastXMLList {
        var a = new Array<FastXML>();
        for(e in { iterator: function() { return x.elements; }}) {
            if(e.name == name || name == "*") {
                a.push(new FastXML(e.x));
            } else {
                var fx = new FastXML(e.x);
                a = a.concat(descendants(fx, name).getArray());
            }
        }
        return new FastXMLList(a);
	}

    public static function toString(x: FastXML) : String {
        return x.x.toString();
    }
}