[DBus (name = "org.freedesktop.DBus.Introspectable")]
private interface Introspectable : Object {
    public abstract string Introspect() throws Error;
}

class DBusObject : Object {
    public string busName { get; construct set; }
    public string objectPath { get; construct set; }
    public DBusObject(string dBusPath) {
        string[] parts = dBusPath.split("/", 2);
        if (parts.length != 2) {
            error("Invalid input format in TrayChild.vala. Expected 'busName/objectPath'\n");
        }
        this.busName = parts[0];
        this.objectPath = "/"+parts[1];
    }
}

class MyList<T> : Object {
    private List<T> list;
    public MyList(T a, ...) {
        this.list = new List<T>();
        this.list.append(a);
        var vArgList = va_list();
        for (T? arg = vArgList.arg<T?>(); arg != null ; arg = vArgList.arg<T?>()) {
            this.list.append(arg);
        }
    }
    public void @foreach(Func<T> func){
        list.foreach(func);
    }
}

class TrayChild : Gtk.EventBox {
    private Gtk.Image image;
    public signal void props_gotten();
    public DBusObject dBusObj;
    private string activateName;
    private DBusProxy sNIProxy;
    private DBusProxy menuProxy;
    private Variant menuLayout;
    
    public TrayChild(string itemId) {
        this.dBusObj = new DBusObject(itemId);
        get_properties.begin(new MyList<string>("IconName", "Title", "ToolTip", "Menu"), on_properties_gotten);
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

    private void on_properties_gotten(Object? obj, AsyncResult res) {
        DBusInterfaceInfo dii = this.sNIProxy.get_interface_info();
        DBusMethodInfo? dmi = dii.lookup_method("Activate");
        if (dmi == null) {
            dmi = dii.lookup_method("SecondaryActivate");
        }
        this.activateName = dmi.name;
        this.sNIProxy.g_signal.connect(on_prop_signal);
        this.button_release_event.connect(on_button_release);
        props_gotten();
    }

    private void on_prop_signal(string? sender_name, string signal_name, Variant parameters) {
        switch (signal_name) {
            case "NewIcon":
                get_properties.begin(new MyList<string>("IconName"));
                break;
            case "NewToolTip":
                get_properties.begin(new MyList<string>("ToolTip"));
                break;
        }
    }

    private async void get_properties(MyList<string> properties) {
        DBusInterfaceInfo dii = yield getInterfaceInfo(this.dBusObj.busName, this.dBusObj.objectPath, "org.kde.StatusNotifierItem");
        try {
            this.sNIProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, this.dBusObj.busName, this.dBusObj.objectPath, "org.kde.StatusNotifierItem", null);
            properties.foreach((prop) => {
                Variant? v = this.sNIProxy.get_cached_property(prop);
                if (v != null) {
                    switch(prop) {
                        case "IconName":
                            if (this.get_children().length() != 0) {
                                this.remove(this.image);
                            }
                            this.image = new Gtk.Image.from_icon_name(v.get_string(), Gtk.IconSize.BUTTON);
                            this.image.pixel_size = ValaBar.btnSize;
                            this.add(this.image);
                            this.show_all();
                            break;
                        case "Title":
                            this.tooltip_text = v.get_string();
                            break;
                        case "ToolTip":
                            VariantIter iter = v.iterator();
                            string s = "";
                            iter.next("s");
                            iter.next("a(iiay)");
                            iter.next("s", out s);
                            if (s != "") {
                                this.tooltip_text = s;
                            }
                            break;
                        case "Menu":
                            get_menu_layout.begin(this.dBusObj.busName, v.get_string());
                            break;
                    }
                }
            });
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
    }

    private async void get_menu_layout(string busName, string menuPath) {
        DBusInterfaceInfo dii = yield getInterfaceInfo(busName, menuPath, "com.canonical.dbusmenu");

        try {
            this.menuProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, busName, menuPath, "com.canonical.dbusmenu", null);
            DBusMethodInfo? dmi = dii.lookup_method("GetLayout");
            if (dmi != null) {
                this.menuLayout = yield this.menuProxy.call("GetLayout", new Variant ("(ii^as)", 0, -1, new string[0]), DBusCallFlags.NONE, 5000, null);
                VariantIter iter = this.menuLayout.iterator();
                iter.next("u");
                this.menuLayout = iter.next_value();
                this.menuProxy.g_signal.connect(on_menu_signal);
                //this.menuProxy.LayoutUpdated.connect((ref revision, ref parent) => {print("upd\n");});
                //this.menuProxy.ItemsPropertiesUpdated.connect(onPropsUpd);
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting dbusMenu: %s\n", e.message);
        }
    }

    private void on_menu_signal(string? sender_name, string signal_name, Variant parameters) {
        print("sender: %s, menu signal: %s\n", sender_name, signal_name);
    }

    private Gtk.Menu makeMenu(Variant layout, out Gtk.MenuItem mItem) {
        mItem = null;
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
        iter.next("a{sv}", out iter2);
        if (iter2.n_children() > 0) {
            menuItem = new Gtk.MenuItem();
            menuItemContents = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            menuItemContents.halign = Gtk.Align.START;
            menuItem.add(menuItemContents);
            menuItem.button_press_event.connect((event) => {
                print("clicked\n");
                return true;
            });

            while (iter2.next("{sv}", out key, out val)) {
                switch(key) {
                    case "label":
                        menuItemContents.pack_end(new Gtk.Label(val.get_string()), true, true, 5);
                        break;
                    case "icon-name":
                        menuItemContents.pack_start(new Gtk.Image.from_icon_name(val.get_string(), Gtk.IconSize.BUTTON), true, true, 5);
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
                        break;
                }
            }
            mItem = menuItem;
        }
        iter.next("av", out iter2);
        if (iter2.n_children() > 0) {
            menu = new Gtk.Menu();
            while (iter2.next ("v", out val)) {
                subMenu = makeMenu(val, out menuItem);
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
                this.sNIProxy.call.begin(this.activateName, new Variant("(ii)", 0, 0), DBusCallFlags.NONE, 5000);
                return true;
            } else if (event.button == 3) { //right button
                Gtk.MenuItem mi;
                Gtk.Menu menu = makeMenu(this.menuLayout, out mi);
                if (menu != null) {
                    menu.attach_to_widget(widget, null);
                    menu.deactivate.connect(menu.destroy);
                    menu.show_all();
                    //menu.popup_at_widget(widget, Gdk.Gravity.NORTH_EAST, Gdk.Gravity.SOUTH_EAST, event);
                    menu.popup_at_pointer(event);
                }
                return true;
            }
        }
        return false;
    }
}