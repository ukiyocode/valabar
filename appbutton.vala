public class AppButton : Gtk.Button
{
    public string desktop_file { get; set; }
    public Wnck.Window window { get; }
    private DesktopAppInfo _appInfo;
    public ulong xid { get; set; }
    private int _imgSize;

    private Bamf.Matcher _matcher;

    public AppButton(Wnck.Window window, int size) {
        this.init_for_window(window, size);
    }

    public void init_for_dfile(int size) {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this._imgSize = size;
        if ((this.desktop_file != "") && (this.desktop_file != null)) {
            this._appInfo = new GLib.DesktopAppInfo(desktop_file);
            try {
                this.image = prepare_image(Gtk.IconTheme.get_default().lookup_by_gicon(this._appInfo.get_icon(), 0, 0).load_icon());
            } catch (Error e) {
                stderr.printf("Error while loading icon is appbuton init: %s", e.message);
            }
            this.set_tooltip_text(_appInfo.get_display_name());
        }
        this.button_press_event.connect(on_button_press);
    }

    public void init_for_window(Wnck.Window window, int size) {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this._imgSize = size;
        this._matcher = Bamf.Matcher.get_default();
        this._window = window;
        this.xid = window.get_xid();
        this.desktop_file = GLib.Filename.display_basename(_matcher.get_application_for_xid((uint32)this.xid).get_desktop_file());
        if ((this.desktop_file != "") && (this.desktop_file != null)) {
            this._appInfo = new GLib.DesktopAppInfo(this.desktop_file);
        }
        this.image = prepare_image(window.get_icon());
        this.set_tooltip_text(window.get_name());
        this.window.icon_changed.connect(on_icon_changed);
        this.window.name_changed.connect(on_name_changed);
        this.button_press_event.connect(on_button_press);
    }

    private Gtk.Image prepare_image(Gdk.Pixbuf image) {
        Gdk.Pixbuf background = image.scale_simple(this._imgSize, this._imgSize, Gdk.InterpType.BILINEAR);
        if (this.window != null) {
            try {
                Gdk.Pixbuf overlay = new Gdk.Pixbuf.from_file_at_scale("border.svg", this._imgSize, this._imgSize, true);
                overlay.composite(background, 0, 0, background.width, background.height, 0, 0, 1, 1, Gdk.InterpType.BILINEAR, 250);
            } catch (Error e) {
                stderr.printf ("Error while getting border.svg file: %s", e.message);
            }
        }
        return new Gtk.Image.from_pixbuf(background);
    }

    private void on_icon_changed() {
        this.image = prepare_image(window.get_icon());
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

    private bool on_mitem_action(Gtk.Widget widget, Gdk.EventButton event, string action) {
        Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        ab._appInfo.launch_action(action, new AppLaunchContext());
        parent_menu.popdown();
        return true;
    }

    private bool on_button_press(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS)
        {
            AppButton ab = (AppButton)widget;
            if (event.button == 1) { //left button
                if (ab.window != null) {
                    if (!ab.window.is_active()) {
                        ab.window.activate(Gtk.get_current_event_time());           
                    }
                    else {
                        ab.window.minimize();
                    }
                } else {
                    try {
                        ab._appInfo.launch(null, new AppLaunchContext());
                    } catch (Error e) {
                        stderr.printf("Error while launching app: %s\n", e.message);
                    }
                }
                return true;
            } else if ((event.button == 3) && event.triggers_context_menu()) { //right button
                Gtk.Menu menu = new Gtk.Menu();
                string[] actions = ab._appInfo.list_actions();
                if (actions.length > 0) {
                    foreach (string action in actions) {
                        Gtk.MenuItem mitem_action = new Gtk.MenuItem.with_label(ab._appInfo.get_action_name(action));
                        mitem_action.button_release_event.connect((widget, event) => on_mitem_action(widget, event, action));
                        menu.add(mitem_action);
                    }
                }
                if (ab.window != null) {
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
                    menu.add(mitem_minimize);
                    menu.add(mitem_maximize);
                    menu.add(mitem_close);
                }
                menu.deactivate.connect(menu.destroy);
                menu.attach_to_widget(widget, null);
                menu.show_all ();
                menu.popup_at_widget (widget, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, event);
                return true;
            }
        }
        return false;
    }
}