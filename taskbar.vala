public class TaskBar : Gtk.Box
{
    private Wnck.Screen scr;
    public int init() {
        scr = Wnck.Screen.get_default ();
        if (scr == null) {
            stderr.printf("Unable to get the default screen.\n");
            return 1;
        }
        scr.force_update();
        unowned List<Wnck.Window> wnds = scr.get_windows();

        foreach (Wnck.Window wnd in wnds) {
            if (wnd.get_window_type() == Wnck.WindowType.NORMAL) {
                this.add(new WindowButton(wnd, 30)); 
            }
        }
        scr.window_closed.connect(on_window_closed);
        scr.window_opened.connect(on_window_opened);
        return 0;
    }

    private void on_window_closed(Wnck.Window win) {
        stdout.printf("%lu\n", win.get_xid());
    }

    private void on_window_opened(Wnck.Window win) {
        stdout.printf("%lu\n", win.get_xid());
    }
}