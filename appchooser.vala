public class AppChooser : Gtk.Dialog
{
    List<AppInfo> apps;

    public AppChooser() {
        apps = GLib.AppInfo.get_all();
        this.set_default_size(400, 500);
        Gtk.Box contentArea = this.get_content_area () as Gtk.Box;
        Gtk.ScrolledWindow scrWin = new Gtk.ScrolledWindow(null, null);
        Gtk.ListBox listBox = new Gtk.ListBox();
		scrWin.add(listBox);
        contentArea.pack_start (scrWin, false, true, 0);
    }

    public GLib.AppInfo get_app_info() {
        return apps.nth_data(0);
    }
}