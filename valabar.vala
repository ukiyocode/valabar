public class ValaBar : Gtk.Window
{
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }

    public static int main(string[] args)
    {
        Gtk.init (ref args);
        TaskBar taskbar;
        string exePath;

        var builder = new Gtk.Builder ();
        try {
            exePath = GLib.Path.get_dirname(GLib.FileUtils.read_link("/proc/self/exe"));
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_path(exePath + "/style.css");
            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            // If the UI contains custom widgets, their types must've been instantiated once
            // Type type = typeof(Foo.BarEntry);
            // assert(type != 0);
            builder.add_from_file(exePath + "/valabar.ui");

            taskbar = builder.get_object("taskbar") as TaskBar;
            taskbar.init_();

            builder.connect_signals(null);
            var window = builder.get_object("window") as ValaBar;
            window.move(window.x, window.y);
            window.show_all ();

            Gtk.main ();
        } catch (Error e) {
            stderr.printf("Could not load UI: %s\n", e.message);
            return 1;
        }
        return 0;
    }
}