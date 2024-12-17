public class SystemTray : Gtk.Box, Gtk.Buildable
{
    private List<TrayChild> items;
    //private NotifierHost notifierHost;
    private StatusNotifierWatcher notifierWatcher;

    public void parser_finished(Gtk.Builder builder) {
        this.items = new List<TrayChild>();
        this.notifierWatcher = new StatusNotifierWatcher();
        this.notifierWatcher.StatusNotifierItemRegistered.connect(on_item_added);
        this.notifierWatcher.StatusNotifierItemUnregistered.connect(on_item_removed);
        //this.notifierWatcher.StatusNotifierHostRegistered.connect(on_host_added);
        this.show_all();
    }

    public bool on_host_added() {
        string[] items = notifierWatcher.RegisteredStatusNotifierItems;
        for (int i = 0; i < items.length; i++) {
            add_tray_child(items[i]);
        }
        return true;
    }

    private bool on_item_added(string id) {
        add_tray_child(id);
        return true;
    }

    private bool on_item_removed(string id) {
        foreach (Gtk.Widget widget in this.get_children()) {
            TrayChild tc = (TrayChild)widget;
            DBusObject dbo = new DBusObject(id);
            if (tc.dBusObj.busName == dbo.busName) {
                this.remove(tc);
                tc = null;
                return true;
            }
        }
        return false;
    }

    private void add_tray_child(string id) {
        TrayChild tc = new TrayChild(id);
        tc.props_gotten.connect((tc) => {
            this.pack_end(tc, true, true, 5);
            this.show_all();
        });
    }
}