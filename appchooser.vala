public class AppChooser : Gtk.Dialog
{
    List<AppInfo> apps;

    public AppChooser() {
        apps = GLib.AppInfo.get_all();
        this.set_default_size(400, 500);
        Gtk.Box contentArea = this.get_content_area () as Gtk.Box;
        Gtk.ScrolledWindow scrWin = new Gtk.ScrolledWindow(null, null);
        Gtk.ListBox listBox = new Gtk.ListBox();
        foreach (GLib.AppInfo ai in apps) {
            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            Gtk.IconInfo ii = Gtk.IconTheme.get_default().lookup_by_gicon(ai.get_icon(), 0, 0);
            stdout.printf("%s\n",ii.get_filename());
            //Gdk.Pixbuf pb = Gtk.IconTheme.get_default().load_icon(ai.get_icon(), 16, Gtk.IconLookupFlags.DIR_LTR);
            box.pack_start(new Gtk.Image.from_gicon(ai.get_icon(), Gtk.IconSize.BUTTON), false, false, 0);
            box.pack_start(new Gtk.Label(ai.get_display_name()), false, true, 0);
            listBox.add(box);
        }
		scrWin.add(listBox);
        contentArea.pack_start (scrWin, true, true, 0);
        this.show_all();
    }

    public GLib.AppInfo get_app_info() {
        return apps.nth_data(0);
    }
}