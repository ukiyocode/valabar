public class AppButton : Gtk.Button
{
    public Wnck.Window window { get; }
    public DesktopAppInfo appInfo { get; }
    public ulong xid { get; set; }
    public int imgSize { get; }

    private Bamf.Matcher _matcher;

    public AppButton(Wnck.Window window, int size) {
        this._matcher = Bamf.Matcher.get_default();
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this._imgSize = size;
        this._window = window;
        this.xid = window.get_xid();
        string desktopFile = _matcher.get_application_for_xid((uint32)this.xid).get_desktop_file();
        this._appInfo = new GLib.DesktopAppInfo.from_filename(desktopFile);
        Gtk.Image img = new Gtk.Image.from_gicon(new GLib.DesktopAppInfo.from_filename(this.desktopFile).get_icon(), Gtk.IconSize.DIALOG);
        img.pixel_size = size;
        this.image = img;
        this.set_tooltip_text(window.get_name());
        this.window.state_changed.connect(on_state_changed);
        this.window.icon_changed.connect(on_icon_changed);
        this.window.name_changed.connect(on_name_changed);
        this.button_press_event.connect(on_button_press);

        stdout.printf("%lu %s\n", this.window.get_xid(), this.window.get_name());
    }

    private void on_state_changed(Wnck.WindowState changed_mask, Wnck.WindowState new_state) {
        stdout.printf("%i %i\n", new_state, changed_mask);
    }

    private void on_icon_changed() {
        Gtk.Image img = new Gtk.Image.from_gicon(new GLib.DesktopAppInfo.from_filename(this.desktopFile).get_icon(), Gtk.IconSize.DIALOG);
        img.pixel_size = imgSize;
        this.image = img;
    }

    private void on_name_changed() {
        this.set_tooltip_text(this.window.get_name());
    }

    private bool on_mitem_close(Gtk.Widget widget, Gdk.EventButton event) {
        Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        ab.window.close(Gtk.get_current_event_time());
        return true;
    }

    private bool on_button_press(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS)
        {
            AppButton wb = (AppButton)widget;
            if (event.button == 1) { //left button
                if (!wb.window.is_active()) {
                    wb.window.activate(Gtk.get_current_event_time());           
                }
                else {
                    wb.window.minimize();
                }
                return true;
            } else if ((event.button == 3) && event.triggers_context_menu()) { //right button
                Gtk.Menu menu = new Gtk.Menu();
                Gtk.MenuItem mitem_close = new Gtk.MenuItem.with_label("Close");
                mitem_close.button_release_event.connect(on_mitem_close);
                menu.deactivate.connect(menu.destroy);
                menu.attach_to_widget(widget, null);
                menu.add(mitem_close);
                menu.show_all ();
                menu.popup_at_widget (widget, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, event);
                return true;
            }
        }
        return false;
    }
}