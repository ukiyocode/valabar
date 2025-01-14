public class ValaBarApp : Gtk.Application {
    public ValaBarApp () {
        Object (
            application_id: "my.valabar",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        print("%s\n", GLib.Environment.get_variable("XDG_SESSION_TYPE"));
        try {
            ValaBar.exePath = GLib.Path.get_dirname(GLib.FileUtils.read_link("/proc/self/exe"));
        } catch (FileError fe) {
            error("Couldn't get exePath: %s", fe.message);
        }
        Logger.init_logging();
        
        Gtk.Builder builder = new Gtk.Builder ();
        try {
            Gtk.CssProvider css_provider = new Gtk.CssProvider();
            css_provider.load_from_path(ValaBar.exePath + "/style.css");
            Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            builder.add_from_file(ValaBar.exePath + "/valabar.ui");
            Gtk.ApplicationWindow window = (Gtk.ApplicationWindow)builder.get_object("window");
            if (window == null) {
                error("Failed to load the main window.");
            }
            window.application = this;
            //builder.connect_signals(null);
        } catch (Error e) {
            error("Could not load UI: %s\n", e.message);
        }
    }

    public static int main(string[] args) {
        return new ValaBarApp().run(args);
    }
}