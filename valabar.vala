public class ValaBar : Gtk.Window
{
    Wnck.Tasklist tasklist;
    Gdk.Monitor curmon;
    
    public ValaBar()
    {
        this.title = "ValaBar";
        this.set_type_hint(Gdk.WindowTypeHint.DOCK);
        this.set_decorated(false);
        this.set_default_size(400, 30);
        this.destroy.connect(Gtk.main_quit);

        curmon = Gdk.Display.get_default().get_monitor_at_window(this.get_window());
        this.move(620,curmon.geometry.height-300);
        
        var grid = new Gtk.Grid();
        grid.set_row_spacing(5);
        grid.set_column_spacing(5);
        this.add(grid);

        tasklist = new Wnck.Tasklist();
        tasklist.set_grouping(Wnck.TasklistGroupingType.NEVER_GROUP);
        grid.attach(tasklist, 0, 0, 1, 1);
    }

    public static int main(string[] args)
    {
        Gtk.init (ref args);
        try {
            // If the UI contains custom widgets, their types must've been instantiated once
            // Type type = typeof(Foo.BarEntry);
            // assert(type != 0);
            var builder = new Gtk.Builder ();
            builder.add_from_file ("valabar.ui");
            builder.connect_signals (null);
            var window = builder.get_object ("window") as Gtk.Window;
            window.show_all ();
            Gtk.main ();
        } catch (Error e) {
            stderr.printf ("Could not load UI: %s\n", e.message);
            return 1;
        }
        return 0;
        //ValaBar window = new ValaBar();
    }
}