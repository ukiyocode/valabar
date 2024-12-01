[DBus (name = "org.kde.StatusNotifierItem")]
private interface NotifierItemIface : Object
{
    public abstract string Id { owned get; }
    public abstract string Title { owned get; }
    public abstract string IconName { owned get; }

    public abstract void Activate(int x, int y) throws Error;
    public abstract void SecondaryActivate(int x, int y) throws Error;
    public abstract void ContextMenu(int x, int y) throws Error;
}

class TrayChild : Gtk.EventBox {    
    private NotifierItemIface proxy;
    private Gtk.Image image;
    public signal void props_gotten();
    
    public TrayChild(string itemId) {
        get_properties.begin(itemId, on_properties_gotten);
    }

    private void on_properties_gotten(Object? obj, AsyncResult res) {
        this.proxy = get_properties.end(res);
        string iconName = this.proxy.IconName;
        this.image = new Gtk.Image.from_icon_name(iconName, Gtk.IconSize.BUTTON);
        if (this.image != null) {
            image.pixel_size = ValaBar.btnSize;
            this.add(this.image);
            props_gotten();
        }
        this.button_release_event.connect(on_button_release);
    }

    public async NotifierItemIface? get_properties(string item_path) {
        NotifierItemIface proxy = null;
        try {
            string[] parts = item_path.split("/", 2);
            if (parts.length != 2) {
                stderr.printf("Invalid input format. Expected 'bus_name/object_path'\n");
                return null;
            }
            string bus_name = parts[0];
            string object_path = "/" + parts[1];

            //proxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, null, bus_name, object_path, "org.kde.StatusNotifierItem", null);
            proxy = yield Bus.get_proxy(BusType.SESSION, bus_name, object_path);
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
        return proxy;
    }

    private bool on_button_release(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_RELEASE)
        {
            if (event.button == 1) { //left button
                //try {
                if (this.proxy.Activate) {
                    print("null");
                }
                    this.proxy.Activate(0, 0);
                //} catch (Error e) {
                //}
                return true;
            } else if (event.button == 3) { //right button
                //try {
                    this.proxy.ContextMenu(0, 0);
                //} catch (Error e) {
                //}
                return true;
            }
        }
        return false;
    }
}