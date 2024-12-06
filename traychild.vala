[DBus (name = "org.freedesktop.DBus.Introspectable")]
private interface Introspectable : Object {
    public abstract string Introspect() throws Error;
}

struct Props {
    public int32 a;
    public HashTable<string, Variant> b;
    public Variant[] c;
}

[DBus (name = "com.canonical.dbusmenu")]
private interface DBusMenuIface : Object {
    public abstract void GetLayout(int32 parentId, int32 recursionDepth, string[] propertyNames, out uint32 revision, out Props layout) throws Error;
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
    private Gtk.Menu menu;
    
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
                get_menu_layout.begin(dobj.busName, v.get_string());
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
        return proxy;
    }

    private async void get_menu_layout(string busName, string menuPath) {
        DBusInterfaceInfo dii = yield getInterfaceInfo(busName, menuPath, "com.canonical.dbusmenu");
        uint32 revision;
        Variant layout;

        try {
            DBusMenuIface proxy = yield Bus.get_proxy(BusType.SESSION, busName, menuPath);
            string methodName = "GetLayout";
            DBusMethodInfo? dmi = dii.lookup_method(methodName);
            if (dmi != null) {
                proxy.GetLayout(0, -1, {}, out revision, out layout);
                Gtk.MenuItem mi;
                this.menu = makeMenu(layout, true, out mi);
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting dbusMenu: %s\n", e.message);
        }
    }

    private Gtk.Menu makeMenu(Variant layout, bool root, out Gtk.MenuItem mItem) {
        int32 id = 0;
        string key;
        Variant val;
        VariantIter iter = layout.iterator();
        VariantIter iter2;
        Gtk.Menu menu = null;
        Gtk.Menu subMenu = null;
        Gtk.MenuItem menuItem = null;
        Gtk.Box menuItemContents = null;
        iter.next("i", out id);
        print("id: %i\n", id);
        iter.next("a{sv}", out iter2);
        if (iter2.n_children() > 0) {
            menuItem = new Gtk.MenuItem();
            menuItemContents = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            menuItem.add(menuItemContents);

            while (iter2.next ("{sv}", out key, out val)) {
                switch (key) {
                    case "icon-name":
                        menuItemContents.add(new Gtk.Image.from_icon_name(val.get_string(), Gtk.IconSize.BUTTON));
                        //print ("Item '%s' has value '%s'\n", key, val.get_string());
                        break;
                    case "label":
                        menuItemContents.add(new Gtk.Label(val.get_string()));
                        //print ("Item '%s' has value '%s'\n", key, val.get_string());
                        break;
                    case "type":
                        if (val.get_string() == "separator") {
                            menuItem = new Gtk.SeparatorMenuItem();
                        } else {
                            error("Unknown menuitem \"type: %s\"", val.get_string());
                        }
                        break;
                    case "enabled":
                        menuItem.sensitive = val.get_boolean();
                        //print ("Item '%s' has value '%s'\n", key, val.get_boolean().to_string());
                        break;
                }
            }
            mItem = menuItem;
        }
        iter.next("av", out iter2);
        if (iter2.n_children() > 0) {
            menu = new Gtk.Menu();
            while (iter2.next ("v", out val)) {
                subMenu = makeMenu(val, false, out menuItem);
                if (subMenu != null) {
                    menuItem.set_submenu(subMenu);
                }
                menu.add(menuItem);
            }
        }
        return menu;
    }

    private bool on_button_release(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_RELEASE)
        {
            if (event.button == 1) { //left button
                this.proxy.call.begin(this.activateName, new Variant("(ii)", 0, 0), DBusCallFlags.NONE, 5000);
                return true;
            } else if (event.button == 3) { //right button
                if (this.menu != null) {
                    this.menu.deactivate.connect(menu.destroy);
                    this.menu.attach_to_widget(widget, null);
                    this.menu.show_all ();
                    this.menu.popup_at_widget (widget, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, event);
                }
                return true;
            }
        }
        return false;
    }
}