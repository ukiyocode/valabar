public class ValaBar : Gtk.Window
{
    public int x { get; set; default = 0; }
    public int y { get; set; default = 0; }
    
    //  public TaskList()
    //  {
    //      tasklist = new Wnck.Tasklist();
    //      tasklist.set_grouping(Wnck.TasklistGroupingType.NEVER_GROUP);
    //      grid.attach(tasklist, 0, 0, 1, 1);
    //  }

    public static int main(string[] args)
    {
        Gtk.init (ref args);
        var builder = new Gtk.Builder ();
        try {
            // If the UI contains custom widgets, their types must've been instantiated once
            // Type type = typeof(Foo.BarEntry);
            // assert(type != 0);
            builder.add_from_file("valabar.ui");
            builder.connect_signals(null);
            var window = builder.get_object("window") as ValaBar;
            window.move(window.x, window.y);
            //var tasklist = builder.get_object ("tasklist") as Wnck.Tasklist;
            window.show_all ();
            Gtk.main ();
        } catch (Error e) {
            stderr.printf("Could not load UI: %s\n", e.message);
            return 1;
        }
        return 0;
        //ValaBar window = new ValaBar();
    }
}