class TrayChild : Gtk.Bin {    
    private DBusProxy proxy;
    private Gtk.Image image;
    public signal void props_gotten();
    
    public TrayChild(string itemId) {
        get_properties.begin(itemId, on_properties_gotten);
    }

    private void on_properties_gotten(Object? obj, AsyncResult res) {
        this.proxy = get_properties.end(res);
        Variant? value = proxy.get_cached_property("IconName");
        if (value != null) {
            this.image = new Gtk.Image.from_icon_name(value.get_string(), Gtk.IconSize.BUTTON);
            if (this.image != null) {
                image.pixel_size = ValaBar.btnSize;
                this.add(this.image);
                props_gotten();
            }
        }
    }

    public async DBusProxy? get_properties(string item_path) {
        DBusProxy proxy = null;
        try {
            string[] parts = item_path.split("/", 2);
            if (parts.length != 2) {
                stderr.printf("Invalid input format. Expected 'bus_name/object_path'\n");
                return null;
            }
            string bus_name = parts[0];
            string object_path = "/" + parts[1];

            proxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, null, bus_name, object_path, "org.kde.StatusNotifierItem", null);

        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
        return proxy;
    }

    /*private string format_value(Variant value) {
        if (value.is_of_type(new VariantType("(iiay)"))) {
            // Handle IconPixmap type
            return "<IconPixmap data>";
        } else if (value.is_of_type(new VariantType("a(iiay)"))) {
            return "<Array of IconPixmap data>";
        } else if (value.is_of_type(new VariantType("(sa(iiay)ss)"))) {
            // Handle ToolTip type
            return "<ToolTip data>";
        } else {
            return value.print(true);
        }
    }*/
}