public class ValaBar : Gtk.Window
{
    public static int btnSize = 0;
    public static string exePath = "";
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }

    public void init(Gtk.Builder builder, string _exePath) {
        btnSize = this.default_height - 3;
        exePath = _exePath;
        TaskBar taskbar = builder.get_object("taskbar") as TaskBar;
        taskbar.init();

        builder.connect_signals(null);
        this.move(this.x, this.y);

        this.button_press_event.connect(on_button_press);
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
            if (valabar == null) {
                throw new MarkupError.INVALID_CONTENT("Malformed valabar.ui");
            }
            valabar.init(builder, _exePath);
            valabar.show_all ();
            //string stuff;
            //GLib.FileUtils.get_contents (string filename, out string contents, out size_t length = null) throws FileError 
            //print();
        } catch (Error e) {
            stderr.printf("Could not load UI: %s\n", e.message);
            return 1;
        }
        CPUUsageMeter cpuMeter = new CPUUsageMeter();
        cpuMeter.perCoreCPUUsageCallback();
        //  TimeoutSource time = new TimeoutSource (2000);
        //  time.set_callback (() => {
        //      print ("Time!\n");
        //      return true;
        //  });
        //  time.attach(null);

        Gtk.main ();

        return 0;
    }
}