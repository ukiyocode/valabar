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
        Gtk.init(ref args);

        ValaBar window = new ValaBar();
        window.show_all();

        Gtk.main();

        return 0;
    }
}