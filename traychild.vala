class DBusPath : Object {
    public string busName { get; construct set; }
    public string objectPath { get; construct set; }
    public DBusPath(string dBusPath) {
        string[] parts = dBusPath.split("/", 2);
        if (parts.length != 2) {
            error("Invalid input format in TrayChild.vala. Expected 'busName/objectPath'\n");
        }
        this.busName = parts[0];
        this.objectPath = "/"+parts[1];
    }
}

class TrayChild : Gtk.EventBox {
    public signal void propertiesChanged();
    public StatusNotifierItem statusNotifierItem { get; construct set; }
    private Gtk.Image image;
    private ulong btnReleaseHandlerID; 
    
    public TrayChild(string dBusPath) {
        this.statusNotifierItem = new StatusNotifierItem(dBusPath);
        this.statusNotifierItem.itemReady.connect(onItemReady);
        this.statusNotifierItem.getSNIProperties.begin(true, (obj, res) => { this.statusNotifierItem.getSNIProperties.end(res); });
        btnReleaseHandlerID = 0;
    }

    private void onItemReady() {
        if (this.get_children().length() != 0) {
            this.remove(this.image);
        }
        this.image = new Gtk.Image.from_icon_name(this.statusNotifierItem.iconName, Gtk.IconSize.BUTTON);
        this.image.pixel_size = ValaBar.btnSize;
        this.add(this.image);
        this.tooltip_text = this.statusNotifierItem.toolTip;

        if (btnReleaseHandlerID == 0) {
            this.btnReleaseHandlerID = this.button_release_event.connect(on_button_release);
        }
        propertiesChanged();
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
                this.statusNotifierItem.menuItemClicked(id);
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
                this.statusNotifierItem.activate();
                return true;
            } else if (event.button == 3) { //right button
                Gtk.MenuItem mi;
                Gtk.Menu menu = makeMenu(this.statusNotifierItem.menuLayout, out mi);
                if (menu != null) {
                    menu.attach_to_widget(widget, null);
                    menu.deactivate.connect(menu.destroy);
                    menu.show_all();
                    menu.popup_at_pointer(event);
                }
                return true;
            }
        }
        return false;
    }
}