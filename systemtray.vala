public class SystemTray : Gtk.Box, Gtk.Buildable
{
    private List<TrayChild> items;
    private NotifierHost notifierHost;

    public void parser_finished(Gtk.Builder builder) {
        items = new List<TrayChild>();
        StatusNotifierWatcher snw = new StatusNotifierWatcher();
        snw.RegisterStatusNotifierHost("org.kde.StatusNotifierWatcher");
        /*notifierHost = new NotifierHost("org.kde.StatusNotifierWatcher");
        notifierHost.watcher_item_added.connect(on_item_added);
        notifierHost.watcher_item_removed.connect(on_item_removed);
        notifierHost.watcher_host_added.connect(on_host_added);*/
        this.show_all();
    }

    public void on_host_added() {
        string[] items = notifierHost.watcher_items();
        print("items ln: %i\n", items.length);
        for (int i = 0; i < items.length; i++) {
            add_tray_child(items[i]);
        }
    }

    private void on_item_added(string id) {
        print("iii\n");
        add_tray_child(id);
    }

    private void on_item_removed(string id) {
        foreach (Gtk.Widget widget in this.get_children()) {
            TrayChild tc = (TrayChild)widget;
            DBusObject dbo = new DBusObject(id);
            if (tc.dBusObj.busName == dbo.busName) {
                this.remove(tc);
                tc = null;
            }
        }
    }

    private void add_tray_child(string id) {
        TrayChild tc = new TrayChild(id);
        tc.props_gotten.connect((tc) => {
            this.pack_end(tc, true, true, 5);
            this.show_all();
        });
    }
}