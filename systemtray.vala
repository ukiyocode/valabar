public class SystemTray : Gtk.Box, Gtk.Buildable
{
    public void parser_finished(Gtk.Builder builder) {
        string notification_watcher_xml;
        try {
            FileUtils.get_contents("notification_watcher.xml", out notification_watcher_xml);
            DBusNodeInfo dbni = new GLib.DBusNodeInfo.for_xml(notification_watcher_xml);
            unowned GLib.DBusInterfaceInfo interface_info = dbni.lookup_interface("org.kde.StatusNotifierWatcher");
            DBusProxy proxy = new DBusProxy.for_bus_sync(BusType.SESSION, DBusProxyFlags.NONE, interface_info, "org.kde.StatusNotifierWatcher", 
                "/StatusNotifierWatcher", "org.kde.StatusNotifierWatcher");
            proxy.g_signal.connect(on_g_signal);
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
        }
    }

    private void on_g_signal (string? sender_name, string signal_name, Variant parameters) {
        print("sig\n");
    }
}