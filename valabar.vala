public class ValaBar : Gtk.Window, Gtk.Buildable
{
    public static int btnSize;
    public static string exePath;
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }

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

    public void set_buildable_property(Gtk.Builder builder, string name, Value value) {
        base.set_buildable_property(builder, name, value);
        if (name == "default-height") {
            btnSize = value.get_int() - 3;
        }
    }

    public void parser_finished(Gtk.Builder builder) {
        this.move(this.x, this.y);
        this.button_press_event.connect(on_button_press);

        int scale = this.get_scale_factor();
        Gdk.Rectangle primary_monitor = this.screen.get_display().get_primary_monitor().get_geometry();
        long struts[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        struts[Struts.BOTTOM] = (this.default_height + this.screen.get_height() - primary_monitor.y - primary_monitor.height) * scale;
        struts[Struts.BOTTOM_START] = primary_monitor.x * scale;
        struts[Struts.BOTTOM_END] = (primary_monitor.x + primary_monitor.width) * scale - 1;
        this.realize();
        Gdk.property_change(this.get_window(), Gdk.Atom.intern("_NET_WM_STRUT", false), Gdk.Atom.intern("CARDINAL", false),
            32, Gdk.PropMode.REPLACE, (uint8[])struts, 4);
        Gdk.property_change(this.get_window(), Gdk.Atom.intern("_NET_WM_STRUT_PARTIAL", false), Gdk.Atom.intern("CARDINAL", false),
            32, Gdk.PropMode.REPLACE, (uint8[])struts, 12);
    
        this.show_all();
    }

    private bool on_button_press(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS)
        {
            if ((event.button == 3) && event.triggers_context_menu()) { //right button
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
            return 1;
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
            return 1;
        }

        Gtk.main ();

        return 0;
    }
}