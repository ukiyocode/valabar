public class AppButton : Gtk.Button
{
    public Wnck.Window window { get; }
    public DesktopAppInfo? appInfo { get; }
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
        if ((desktopFile != "") && (desktopFile != null)) {
            this._appInfo = new GLib.DesktopAppInfo.from_filename(desktopFile);
        }
        this.image = new Gtk.Image.from_pixbuf(window.get_icon().scale_simple(this.imgSize, this.imgSize, Gdk.InterpType.BILINEAR));
        this.set_tooltip_text(window.get_name());
        this.window.icon_changed.connect(on_icon_changed);
        this.window.name_changed.connect(on_name_changed);
        this.button_press_event.connect(on_button_press);

        //stdout.printf("%s\n", desktopFile);
    }

    private void on_icon_changed() {
        this.image = new Gtk.Image.from_pixbuf(window.get_icon().scale_simple(this.imgSize, this.imgSize, Gdk.InterpType.BILINEAR));
    }

    private void on_name_changed() {
        this.set_tooltip_text(this.window.get_name());
    }

    private bool on_mitem_close(Gtk.Widget widget, Gdk.EventButton event) {
        Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        ab.window.close(Gtk.get_current_event_time());
        parent_menu.popdown();
        return true;
    }

    private bool on_mitem_maximize(Gtk.Widget widget, Gdk.EventButton event) {
        Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        if (ab.window.is_maximized()) {
            ab.window.unmaximize();
        } else {
            ab.window.maximize();
        }
        parent_menu.popdown();
        return true;
    }

    private bool on_mitem_minimize(Gtk.Widget widget, Gdk.EventButton event) {
        Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        if (ab.window.is_minimized()) {
            ab.window.unminimize(Gtk.get_current_event_time());
        } else {
            ab.window.minimize();
        }
        parent_menu.popdown();
        return true;
    }

    private bool on_button_press(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS)
        {
            AppButton ab = (AppButton)widget;
            if (event.button == 1) { //left button
                if (!ab.window.is_active()) {
                    ab.window.activate(Gtk.get_current_event_time());           
                }
                else {
                    ab.window.minimize();
                }
                return true;
            } else if ((event.button == 3) && event.triggers_context_menu()) { //right button
                Gtk.Menu menu = new Gtk.Menu();
                Gtk.MenuItem mitem_close = new Gtk.MenuItem.with_label("Close");
                Gtk.MenuItem mitem_maximize = new Gtk.MenuItem.with_label("Maximize");
                if (ab.window.is_maximized()) {
                    mitem_maximize.label = "Unmaximize";
                }
                Gtk.MenuItem mitem_minimize = new Gtk.MenuItem.with_label("Minimize");
                if (ab.window.is_minimized()) {
                    mitem_minimize.label = "Restore";
                }
                mitem_close.button_release_event.connect(on_mitem_close);
                mitem_maximize.button_release_event.connect(on_mitem_maximize);
                mitem_minimize.button_release_event.connect(on_mitem_minimize);
                menu.deactivate.connect(menu.destroy);
                menu.attach_to_widget(widget, null);
                menu.add(mitem_minimize);
                menu.add(mitem_maximize);
                menu.add(mitem_close);
                menu.show_all ();
                menu.popup_at_widget (widget, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, event);
                print("hhh");
                return true;
            }
        }
        return false;
    }
}