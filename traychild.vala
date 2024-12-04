[DBus (name = "org.freedesktop.DBus.Introspectable")]
private interface Introspectable : Object {
    public abstract string Introspect() throws Error;
}

class TrayChild : Gtk.EventBox {
    private Gtk.Image image;
    private string iconName;
    public signal void props_gotten();
    public string dBusPath;
    private string activateName;
    private DBusProxy proxy;
    private string menuPath;
    
    public TrayChild(string itemId) {
        this.dBusPath = itemId;
        getIntrospect.begin(itemId);
    }

    private async void getIntrospect(string item_path) {
        Introspectable proxy = null;
        string xml_data = "";
        try {
            string[] parts = item_path.split("/", 2);
            if (parts.length != 2) {
                debug("Invalid input format in TrayChild.vala. Expected 'bus_name/object_path'\n");
                return;
            }
            string bus_name = parts[0];
            string object_path = "/" + parts[1];
            proxy = yield Bus.get_proxy(BusType.SESSION, bus_name, object_path);
            xml_data = proxy.Introspect();
            DBusNodeInfo dni = new DBusNodeInfo.for_xml(xml_data);
            DBusInterfaceInfo dii = dni.lookup_interface("org.kde.StatusNotifierItem");
            if (dii != null) {
                get_properties.begin(item_path, dii, on_properties_gotten);
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while introspecting StatusNotifierItem: %s\n", e.message);
        }
        return;
    }

    private void on_properties_gotten(Object? obj, AsyncResult res) {
        this.proxy = get_properties.end(res);
        DBusInterfaceInfo dii = proxy.get_interface_info();
        DBusMethodInfo? dmi = dii.lookup_method("Activate");
        if (dmi == null) {
            dmi = dii.lookup_method("SecondaryActivate");
        }
        this.activateName = dmi.name;
        this.button_release_event.connect(on_button_release);
        props_gotten();
    }

    private async DBusProxy get_properties(string item_path, DBusInterfaceInfo dii) {
        DBusProxy proxy = null;
        try {
            string[] parts = item_path.split("/", 2);
            if (parts.length != 2) {
                debug("Invalid input format in TrayChild.vala. Expected 'bus_name/object_path'\n");
                return proxy;
            }
            string bus_name = parts[0];
            string object_path = "/" + parts[1];

            proxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, bus_name, object_path, "org.kde.StatusNotifierItem", null);
            Variant? v = proxy.get_cached_property("IconName");
            if (v != null) {
                this.iconName = v.get_string();
                this.image = new Gtk.Image.from_icon_name(this.iconName, Gtk.IconSize.BUTTON);
                if (this.image != null) {
                    image.pixel_size = ValaBar.btnSize;
                    this.add(this.image);
                }
            }
            v = proxy.get_cached_property("Menu");
            if (v != null) {
                this.menuPath = v.get_string();
                print("%s\n", this.menuPath);
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
        return proxy;
    }

    private bool on_button_release(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_RELEASE)
        {
            if (event.button == 1) { //left button
                this.proxy.call.begin(this.activateName, new Variant("(ii)", 0, 0), DBusCallFlags.NONE, 5000);
                return true;
            } else if (event.button == 3) { //right button
                //try {
                    //this.proxy.ContextMenu(0, 0);
                //} catch (Error e) {
                //}
                return true;
            }
        }
        return false;
    }
}