public class AppChooser : Gtk.Dialog
{
    List<AppInfo> apps;
    int selectedRowIndex;

    public AppChooser() {
        apps = GLib.AppInfo.get_all();
        selectedRowIndex = 0;
        this.set_default_size(400, 500);
        Gtk.Box contentArea = this.get_content_area () as Gtk.Box;
        Gtk.ScrolledWindow scrWin = new Gtk.ScrolledWindow(null, null);
        Gtk.ListBox listBox = new Gtk.ListBox();
        foreach (GLib.AppInfo ai in apps) {
            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            GLib.Icon icon = ai.get_icon();
            string name = ai.get_display_name();
            if ((icon != null) && (name != "")) {
                Gtk.Image img = new Gtk.Image.from_gicon(icon, Gtk.IconSize.BUTTON);
                img.pixel_size = 16;
                box.pack_start(img, false, false, 0);
                box.pack_start(new Gtk.Label(ai.get_display_name()), false, true, 0);
                listBox.add(box);
            }
        }
        listBox.row_activated.connect(on_row_activated);
		scrWin.add(listBox);
        contentArea.pack_start (scrWin, true, true, 0);
        this.show_all();
    }

    void on_row_activated(Gtk.ListBoxRow row) {
        this.selectedRowIndex = row.get_index();
        stdout.printf(" Name: %s\n", apps.nth_data(selectedRowIndex).get_display_name ());
    }

    public GLib.AppInfo get_app_info() {
        return apps.nth_data(selectedRowIndex);
    }
}