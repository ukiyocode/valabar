public class ValaBar : Gtk.Window
{
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }

    public void init(Gtk.Builder builder) {
        TaskBar taskbar = builder.get_object("taskbar") as TaskBar;
        taskbar.init();

        builder.connect_signals(null);
        this.move(this.x, this.y);

        //  Gtk.AppChooserDialog dialog = new Gtk.AppChooserDialog(window, 0, GLib.File.new_for_path("_"));
        //  if (dialog.run () == Gtk.ResponseType.OK) {
        //      AppInfo info = dialog.get_app_info ();
        //      if (info != null) {
        //          print (" Name: %s\n", info.get_display_name ());
        //          print (" Desc: %s\n", info.get_description ());
        //      }
        //  }
        //  dialog.close ();
    }

    public static int main(string[] args)
    {
        ValaBar valabar;
        Gtk.Builder builder;
        string _exePath;

        Gtk.init (ref args);
        builder = new Gtk.Builder ();
        try {
            _exePath = GLib.Path.get_dirname(GLib.FileUtils.read_link("/proc/self/exe"));
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_path(_exePath + "/style.css");
            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            builder.add_from_file(_exePath + "/valabar.ui");
            builder.connect_signals(null);
            valabar = builder.get_object("window") as ValaBar;
            valabar.init(builder);
            valabar.show_all ();
        } catch (Error e) {
            stderr.printf("Could not load UI: %s\n", e.message);
            return 1;
        }
        Gtk.main ();

        return 0;
    }
}