public class ValaBar : Gtk.ApplicationWindow, Gtk.Buildable
{
    public const int btnSizeDelta = 3;
    public static string exePath;
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }
    public string monitor { get; set; default = "0"; }

    private enum Struts {
        LEFT,
        RIGHT,
        TOP,
        BOTTOM,
        LEFT_START,
        LEFT_END,
        RIGHT_START,
        RIGHT_END,
        TOP_START,
        TOP_END,
        BOTTOM_START,
        BOTTOM_END
    }

    public static string get_line_from_file(string filePath) {
        File file = File.new_for_path (filePath);
        if (!file.query_exists()) {
            return "";
        }
        string ret = "";
        try {
            FileInputStream fis = file.read();
            DataInputStream dis = new DataInputStream(fis);
            ret = dis.read_line();
        } catch (Error e) {
            error("Error in battery get_line_from_file: %s\n", e.message);
        }
        return ret;
    }

    /*private int getScreenHeight(Gdk.Screen screen) {
        Gdk.Display disp = this.screen.get_display();
        int monitorCount = disp.get_n_monitors();
        int screenHeight = 0;
        Gdk.Rectangle geom;

        for (int i = 0; i < monitorCount; i++) {
            geom = disp.get_monitor(i).get_geometry();
            if ((geom.y + geom.height) > screenHeight) {
                screenHeight = geom.y + geom.height;
            }
        }
        return screenHeight;
    }*/

    private Gdk.Rectangle getGeometry() {
        Gdk.Display disp = this.display;
        ListModel monitors = disp.get_monitors();
        uint monitorNum = 0;
        uint monitorCount = monitors.get_n_items();

        for (uint i = 0; i < monitorCount; i++) {
            Gdk.Monitor mon = (Gdk.Monitor)monitors.get_item(i);
            if (this.monitor.casefold() == mon.connector.casefold()) {
                return mon.get_geometry();
            }
        }
        int.try_parse(this.monitor, out monitorNum);;
        return ((Gdk.Monitor)monitors.get_item(monitorNum)).geometry;
    }

    public void parser_finished(Gtk.Builder builder) {
        int scale = this.get_scale_factor();
        Gdk.Rectangle monitorGeometry = this.getGeometry();
        long struts[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    
        this.present();
        if (this.display is Gdk.X11.Display) {
            unowned X.Display xdisplay = ((Gdk.X11.Display)display).get_xdisplay();
            Gdk.Surface surface = this.get_surface();
            if (surface is Gdk.X11.Surface) {
                xdisplay.move_window(((Gdk.X11.Surface)surface).get_xid(), this.x + monitorGeometry.x, this.y + monitorGeometry.y);
            }
        }
        struts[Struts.BOTTOM] = this.default_height * scale;
        struts[Struts.BOTTOM_START] = monitorGeometry.x * scale;
        struts[Struts.BOTTOM_END] = (monitorGeometry.x + monitorGeometry.width) * scale - 1;
        /*Gdk.property_change(this.get_window(), Gdk.Atom.intern("_NET_WM_STRUT", false), Gdk.Atom.intern("CARDINAL", false),
            32, Gdk.PropMode.REPLACE, (uint8[])struts, 4);
        Gdk.property_change(this.get_window(), Gdk.Atom.intern("_NET_WM_STRUT_PARTIAL", false), Gdk.Atom.intern("CARDINAL", false),
            32, Gdk.PropMode.REPLACE, (uint8[])struts, 12);*/

        //this.button_release_event.connect(on_button_release);
    }

    /*private bool on_button_release(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_RELEASE)
        {
            if (event.button == 3) { //right button
                Gtk.Menu menu = new Gtk.Menu();
                Gtk.MenuItem mitem_favs = new Gtk.MenuItem.with_label("Favs");
                mitem_favs.button_release_event.connect(on_mitem_favs);
                menu.deactivate.connect(menu.destroy);
                menu.attach_to_widget(widget, null);
                menu.add(mitem_favs);
                menu.show_all ();
                menu.popup_at_pointer (event);
                return true;
            }
        }
        return false;
    }

    private bool on_mitem_favs(Gtk.Widget widget, Gdk.EventButton event) {
        AppChooser dialog = new AppChooser();
        if (dialog.run () == Gtk.ResponseType.OK) {
            AppInfo info = dialog.get_app_info ();
            if (info != null) {
                print (" Name: %s\n", info.get_display_name ());
                print (" Desc: %s\n", info.get_description ());
            }
        }
        dialog.close ();
        return true;
    }*/
}