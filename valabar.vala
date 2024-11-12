public class ValaBar : Gtk.Window
{
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }
    private string _exePath;

    public ValaBar() {
        Gtk.Builder builder = new Gtk.Builder ();
        try {
            //  GLib.List<GLib.AppInfo> apps = GLib.AppInfo.get_all();
            //  foreach (GLib.AppInfo ai in apps) {
            //      stdout.printf("%s | %s\n", ai.get_name(), ai.get_id());
            //  }
            _exePath = GLib.Path.get_dirname(GLib.FileUtils.read_link("/proc/self/exe"));
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_path(_exePath + "/style.css");
            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            // If the UI contains custom widgets, their types must've been instantiated once
            // Type type = typeof(Foo.BarEntry);
            // assert(type != 0);
            builder.add_from_file(_exePath + "/valabar.ui");

            TaskBar taskbar = builder.get_object("taskbar") as TaskBar;
            taskbar.init_();

            builder.connect_signals(null);
            this = builder.get_object("window") as ValaBar;
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

        } catch (Error e) {
            stderr.printf("Could not load UI: %s\n", e.message);
            return;
        }
    }

    public static int main(string[] args)
    {
        Gtk.init (ref args);
        ValaBar valabar = new ValaBar();    
        valabar.show_all ();
        Gtk.main ();

        return 0;
    }
}