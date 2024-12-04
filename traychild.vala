[DBus (name = "org.freedesktop.DBus.Introspectable")]
private interface Introspectable : Object {
    public abstract string Introspect() throws Error;
}

class DBusObject : Object {
    public string busName { get; construct set; }
    public string objectPath { get; construct set; }
    public DBusObject(string busName, string objectPath) {
        this.busName = busName;
        this.objectPath = objectPath;
    }
}

class TrayChild : Gtk.EventBox {
    private Gtk.Image image;
    private string iconName;
    public signal void props_gotten();
    public string dBusPath;
    private string activateName;
    private DBusProxy proxy;
    
    public TrayChild(string itemId) {
        this.dBusPath = itemId;
        get_properties.begin(this.dBusPath, on_properties_gotten);
    }

    private async DBusInterfaceInfo? getInterfaceInfo(string busName, string objectPath, string interfaceName) {
        try{
            Introspectable proxy = yield Bus.get_proxy(BusType.SESSION, busName, objectPath);
            string xmlData = proxy.Introspect();
            DBusNodeInfo dni = new DBusNodeInfo.for_xml(xmlData);
            return dni.lookup_interface(interfaceName);
        } catch (Error e) {
            error("Error in TrayChild.vala while introspecting: %s\n", e.message);
        }
    }

    private DBusObject splitPath(string itemPath) {
        string[] parts = itemPath.split("/", 2);
        if (parts.length != 2) {
            error("Invalid input format in TrayChild.vala. Expected 'busName/objectPath'\n");
        }
        return new DBusObject(parts[0], "/"+parts[1]);
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

    private async DBusProxy get_properties(string itemPath) {
        DBusObject dobj = splitPath(itemPath);
        DBusInterfaceInfo dii = yield getInterfaceInfo(dobj.busName, dobj.objectPath, "org.kde.StatusNotifierItem");
        DBusProxy proxy = null;
        try {
            proxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, dobj.busName, dobj.objectPath, "org.kde.StatusNotifierItem", null);
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
                get_menu.begin(dobj.busName, v.get_string());
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
        return proxy;
    }

    private async void get_menu(string busName, string menuPath) {
        DBusProxy menuProxy = null;
        try {
        menuProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, null, busName, menuPath, "com.canonical.dbusmenu", null);
        print("%s\n", menuProxy.get_cached_property("Status").get_string());
        } catch (Error e) {
            error("Error in TrayChild.vala while getting dbusMenu: %s\n", e.message);
        }
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