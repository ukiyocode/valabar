public class SystemTray : Gtk.Box, Gtk.Buildable
{
    /*public void parser_finished(Gtk.Builder builder) {
        string notification_watcher_xml;
        GLib.DBusConnection connection;
        GLib.DBusNodeInfo node_info;
        DBusProxy proxy;
        try {
            print("conn\n");
            connection = GLib.Bus.get_sync(GLib.BusType.SESSION);
            FileUtils.get_contents("notification_watcher.xml", out notification_watcher_xml);
            node_info = new GLib.DBusNodeInfo.for_xml(notification_watcher_xml);
            unowned GLib.DBusInterfaceInfo interface_info = node_info.lookup_interface("org.kde.StatusNotifierWatcher");
            proxy = new DBusProxy.sync(connection, DBusProxyFlags.NONE, null, "org.kde.StatusNotifierWatcher", 
                "/StatusNotifierWatcher", "org.kde.StatusNotifierWatcher");
            proxy.g_signal.connect(on_g_signal);
            proxy.notify.connect(on_notify); 
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
        }
    }

    public void on_notify (ParamSpec pspec) {
        print("notif\n");
    }

    public void on_g_signal (string? sender_name, string signal_name, Variant parameters) {
        print("sig\n");
    }*/
}