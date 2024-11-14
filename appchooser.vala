public class AppChooser : Gtk.Dialog
{
    private List<AppInfo> _apps;
    private int _selectedRowIndex;

    public AppChooser() {
        this._apps = GLib.AppInfo.get_all();
        this._selectedRowIndex = 0;
        this.set_default_size(400, 500);
        Gtk.Box contentArea = this.get_content_area () as Gtk.Box;
        Gtk.ScrolledWindow scrWin = new Gtk.ScrolledWindow(null, null);
        Gtk.ListBox listBox = new Gtk.ListBox();
        foreach (GLib.AppInfo ai in this._apps) {
            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            GLib.Icon icon = ai.get_icon();
            string name = ai.get_id();
            if ((icon != null) && (name != "")) {
                Gtk.Image img = new Gtk.Image.from_gicon(icon, Gtk.IconSize.BUTTON);
                img.pixel_size = 16;
                box.pack_start(img, false, false, 0);
                box.pack_start(new Gtk.Label(name), false, false, 0);
                listBox.add(box);
            }
        }
        listBox.row_activated.connect(on_row_activated);
		scrWin.add(listBox);
        contentArea.pack_start (scrWin, true, true, 0);
        this.show_all();
    }

    void on_row_activated(Gtk.ListBoxRow row) {
        this._selectedRowIndex = row.get_index();
        stdout.printf(" Name: %s\n", this._apps.nth_data(this._selectedRowIndex).get_display_name ());
    }

    public GLib.AppInfo get_app_info() {
        return this._apps.nth_data(this._selectedRowIndex);
    }
}