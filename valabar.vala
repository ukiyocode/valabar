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
        Type tbt = typeof(TaskBar);

        TaskBar taskbar;

        var builder = new Gtk.Builder ();
        try {
            // If the UI contains custom widgets, their types must've been instantiated once
            // Type type = typeof(Foo.BarEntry);
            // assert(type != 0);
            builder.add_from_file("valabar.ui");

            taskbar = builder.get_object("taskbar") as TaskBar;
            taskbar.populate();

            builder.connect_signals(null);
            var window = builder.get_object("window") as ValaBar;
            window.move(window.x, window.y);
            window.show_all ();

            /*Gtk.Window ww = new Gtk.Window();
            ww.set_default_size(800, 60);
            tb = new TaskBar();
            ww.add(tb);
            ww.show_all();*/

            Gtk.main ();
        } catch (Error e) {
            stderr.printf("Could not load UI: %s\n", e.message);
            return 1;
        }
        return 0;
    }
}