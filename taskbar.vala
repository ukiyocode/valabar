public class TaskBar : Gtk.Box
{
    private Wnck.Screen scr;
    private unowned List<Wnck.Window> windows;
    public int btn_size { get; set; }

    public int init() {
        scr = Wnck.Screen.get_default ();
        if (scr == null) {
            stderr.printf("Unable to get the default screen.\n");
            return 1;
        }
        scr.force_update();
        windows = scr.get_windows();

        foreach (Wnck.Window win in windows) {
            if (win.get_window_type() == Wnck.WindowType.NORMAL) {
                this.pack_start(new WindowButton(win, btn_size)); 
            }
        }
        scr.window_closed.connect(on_window_closed);
        scr.window_opened.connect(on_window_opened);
        return 0;
    }

    private void foreach_callback(WindowButton wb, Wnck.Window ww){
        if (wb.xid == ww.get_xid()) {
            wb.unparent();
            wb = null;
        }
    }
    private void on_window_closed(Wnck.Window win) {
        this.foreach ((elem) => foreach_callback((WindowButton)elem, win));
    }

    private void on_window_opened(Wnck.Window win) {
        if (win.get_window_type() == Wnck.WindowType.NORMAL) {
                this.pack_start(new WindowButton(win, btn_size));
                this.queue_draw();
            }
    }
}