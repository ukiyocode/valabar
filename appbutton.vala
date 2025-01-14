public class AppButton : Gtk.Button
{
    public ulong xid { get; }
    //public Wnck.Application app { get; }
    //public Wnck.Window window { get; }
    public DesktopAppInfo appInfo { get; set; }
    private int _imgSize;

    /*public AppButton(Wnck.Window window) {
        this.init_for_window(window);
    }*/

    public AppButton.fromDesktopFile(string dFileName) {
        this.init_for_dfile(dFileName);
    }

    public void init_for_dfile(string dFileName) {
        /*//this._app = null;
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;

        print("default_height: %i", this.get_height());
        this._imgSize = 27;//ValaBar.btnSize;
        //this._window = null;
        this._xid = 0;
        if ((dFileName != "") && (dFileName != null)) {
            this.appInfo = new GLib.DesktopAppInfo.from_filename(dFileName);
            try {
                this.image = prepare_image(Gtk.IconTheme.get_default().lookup_by_gicon(this.appInfo.get_icon(), this._imgSize, 0).load_icon());
            } catch (Error e) {
                stderr.printf("Error while loading icon in appbuton init: %s\n", e.message);
            }
            this.set_tooltip_text(this.appInfo.get_display_name());
        }
        Gtk.GestureClick buttonPressGesture = new Gtk.GestureClick() { button = 0 }; //Any Button
        buttonPressGesture.released.connect(onButtonPress);
        this.add_controller(buttonPressGesture);
        //this.button_press_event.connect(onButtonPress);*/
    }

    /*public void init_for_window(Wnck.Window window) {
        this._app = window.get_application();
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this._imgSize = ValaBar.btnSize;
        this._window = window;
        this._xid = this._window.get_xid();
        this.image = prepare_image(this._window.get_icon());
        this.set_tooltip_text(this._window.get_name());
        this._window.icon_changed.connect(on_icon_changed);
        this._window.name_changed.connect(on_name_changed);
        this.button_press_event.connect(onButtonPress);
    }*/

    public bool isRunning() {
        /*if (this._window != null) {
            return true;
        }*/
        return false;
    }

    private Gtk.Image prepare_image(Gdk.Pixbuf image) {
        if (image == null) {
            print("imgnull\n");
        }
        Gdk.Pixbuf background = image.scale_simple(this._imgSize, this._imgSize, Gdk.InterpType.BILINEAR);
        if (this.isRunning()) {
            try {
                Gdk.Pixbuf overlay = new Gdk.Pixbuf.from_file_at_scale(ValaBar.exePath + "/images/border.svg", this._imgSize, this._imgSize, true);
                overlay.composite(background, 0, 0, background.width, background.height, 0, 0, 1, 1, Gdk.InterpType.BILINEAR, 250);
            } catch (Error e) {
                stderr.printf ("Error while getting border.svg file: %s\n", e.message);
            }
        }
        return new Gtk.Image.from_pixbuf(background);
    }

    private void on_icon_changed() {
        //this.image = prepare_image(this._window.get_icon());
    }

    private void on_name_changed() {
        //this.set_tooltip_text(this._window.get_name());
    }

    private bool onMitemClose(int n_press, double x, double y) {//Gtk.Widget widget, Gdk.EventButton event) {
        /*Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        ab._window.close(Gtk.get_current_event_time());
        parent_menu.popdown();*/
        return true;
    }

    private bool onMitemMaximize(int n_press, double x, double y) {//Gtk.Widget widget, Gdk.EventButton event) {
        /*Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        if (ab._window.is_maximized()) {
            ab._window.unmaximize();
        } else {
            ab._window.maximize();
        }
        parent_menu.popdown();*/
        return true;
    }

    private bool onMitemMinimize(int n_press, double x, double y) {//Gtk.Widget widget, Gdk.EventButton event) {
        /*Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        if (ab._window.is_minimized()) {
            ab._window.unminimize(Gtk.get_current_event_time());
        } else {
            ab._window.minimize();
        }
        parent_menu.popdown();*/
        return true;
    }

    private bool onMitemAction(int n_press, double x, double y) {//Gtk.Widget widget, Gdk.EventButton event, string action) {
        /*Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        AppButton ab = (AppButton)parent_menu.get_attach_widget();
        ab._appInfo.launch_action(action, new AppLaunchContext());
        parent_menu.popdown();*/
        return true;
    }

    private bool onButtonPress(int n_press, double x, double y) {//Gtk.Widget widget, Gdk.EventButton event) {
        /*if (event.type == Gdk.EventType.BUTTON_PRESS)
        {
            AppButton ab = (AppButton)widget;
            if (event.button == 1) { //left button
                if (ab.isRunning()) {
                    if (!ab._window.is_active()) {
                        ab._window.activate(Gtk.get_current_event_time());           
                    }
                    else {
                        ab._window.minimize();
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
                        Gtk.MenuItem mitemAction = new Gtk.MenuItem.with_label(ab._appInfo.get_action_name(action));

                        Gtk.GestureClick mitemActionGesture = new Gtk.GestureClick() { button = 0 }; //Any Button
                        mitemActionGesture.released.connect(onMitemMinimize);
                        mitemAction.add_controller(mitemActionGesture);

                        //mitemAction.button_release_event.connect((widget, event) => onMitemAction(widget, event, action));
                        menu.add(mitemAction);
                    }
                }
                if (ab.isRunning()) {
                    Gtk.MenuItem mitemClose = new Gtk.MenuItem.with_label("Close");
                    Gtk.MenuItem mitemMaximize = new Gtk.MenuItem.with_label("Maximize");
                    if (ab._window.is_maximized()) {
                        mitemMaximize.label = "Unmaximize";
                    }
                    Gtk.MenuItem mitemMinimize = new Gtk.MenuItem.with_label("Minimize");
                    if (ab._window.is_minimized()) {
                        mitemMinimize.label = "Restore";
                    }
                    Gtk.GestureClick mitemCloseGesture = new Gtk.GestureClick() { button = 0 }; //Any Button
                    mitemCloseGesture.released.connect(onMitemClose);
                    mitemClose.add_controller(mitemCloseGesture);

                    Gtk.GestureClick mitemMaximizeGesture = new Gtk.GestureClick() { button = 0 }; //Any Button
                    mitemMaximizeGesture.released.connect(onMitemMaximize);
                    mitemMaximize.add_controller(mitemMaximizeGesture);

                    Gtk.GestureClick mitemMinimizeGesture = new Gtk.GestureClick() { button = 0 }; //Any Button
                    mitemMinimizeGesture.released.connect(onMitemMinimize);
                    mitemMinimize.add_controller(mitemMinimizeGesture);

                    //mitemClose.button_release_event.connect(onMitemClose);
                    //mitemMaximize.button_release_event.connect(onMitemMaximize);
                    //mitemMinimize.button_release_event.connect(onMitemMinimize);
                    menu.add(mitemMinimize);
                    menu.add(mitemMaximize);
                    menu.add(mitemClose);
                }
                menu.deactivate.connect(menu.destroy);
                menu.attach_to_widget(widget, null);
                menu.show_all ();
                menu.popup_at_widget (widget, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, event);
                return true;
            }
        }*/
        return false;
    }
}