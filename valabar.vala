public class ValaBar : Gtk.Window, Gtk.Buildable
{
    public static int btnSize;
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

    public void set_buildable_property(Gtk.Builder builder, string name, Value value) {
        base.set_buildable_property(builder, name, value);
        if (name == "default-height") {
            btnSize = value.get_int() - 3;
        }
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
        Gdk.Display disp = this.screen.get_display();
        int monitorNum = 0;
        int monitorCount = disp.get_n_monitors();

        if (this.monitor == "primary") {
            return disp.get_primary_monitor().get_geometry();
        }
        for (int i = 0; i < monitorCount; i++) {
            if (this.monitor.casefold() == disp.get_monitor(i).model.casefold()) {
                return disp.get_monitor(i).get_geometry();
            }
        }
        int.try_parse(this.monitor, out monitorNum);
        return Gdk.Display.get_default().get_monitor(monitorNum).get_geometry();
    }

    public void parser_finished(Gtk.Builder builder) {
        int scale = this.get_scale_factor();
        Gdk.Rectangle monitorGeometry = this.getGeometry();
        long struts[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        this.realize();
        //print("%i\n", (this.getScreenHeight(this.screen) - (monitorGeometry.y + this.y)) * scale);
        struts[Struts.BOTTOM] = this.default_height * scale;
        struts[Struts.BOTTOM_START] = monitorGeometry.x * scale;
        struts[Struts.BOTTOM_END] = (monitorGeometry.x + monitorGeometry.width) * scale - 1;
        Gdk.property_change(this.get_window(), Gdk.Atom.intern("_NET_WM_STRUT", false), Gdk.Atom.intern("CARDINAL", false),
            32, Gdk.PropMode.REPLACE, (uint8[])struts, 4);
        Gdk.property_change(this.get_window(), Gdk.Atom.intern("_NET_WM_STRUT_PARTIAL", false), Gdk.Atom.intern("CARDINAL", false),
            32, Gdk.PropMode.REPLACE, (uint8[])struts, 12);
    
        this.move(this.x + monitorGeometry.x, this.y + monitorGeometry.y);
        this.button_release_event.connect(on_button_release);
        this.show_all();
    }

    private bool on_button_release(Gtk.Widget widget, Gdk.EventButton event) {
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
    }

    public static int main(string[] args)
    {
        try {
            ValaBar.exePath = GLib.Path.get_dirname(GLib.FileUtils.read_link("/proc/self/exe"));
        } catch (FileError fe) {
            error("Couldn't get exePath: %s", fe.message);
        }
        Logger.init_logging();
        
        Gtk.Builder builder;

        Gtk.init (ref args);
        builder = new Gtk.Builder ();
        try {
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_path(ValaBar.exePath + "/style.css");
            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            builder.add_from_file(ValaBar.exePath + "/valabar.ui");
            builder.connect_signals(null);
        } catch (Error e) {
            error("Could not load UI: %s\n", e.message);
        }

        Gtk.main ();

        return 0;
    }
}