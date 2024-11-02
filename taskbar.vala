public class TaskBar : Gtk.Box
{
    public void populate() {
        Wnck.Screen scr = Wnck.Screen.get_default ();
        if (scr == null) {
            stderr.printf("Unable to get the default screen.\n");
            return;
        }
        scr.force_update();
        unowned List<Wnck.Window> wnds = scr.get_windows();

        foreach (Wnck.Window wnd in wnds) {
            if (wnd.get_window_type() == Wnck.WindowType.NORMAL) {
                //stdout.printf("%s\n", wnd.get_name());
                //stdout.printf("%lu\n", wnd.get_xid());
                //stdout.printf("%s\n", wnd.get_window_type().to_string());
                this.add(new WindowButton(wnd, 30)); 
            }
        }
    }
}