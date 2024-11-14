public class TaskBar : Gtk.Box
{
    private Wnck.Screen scr;
    private unowned List<Wnck.Window> windows;
    public int btnSize { get; }

    public int init(int barHeight) {
        this._btnSize = barHeight - 2;

        foreach (Gtk.Widget child in this.get_children()) {
            AppButton ab = (AppButton)child;
            ab.init_for_dfile(this.btnSize);
        }
        scr = Wnck.Screen.get_default ();
        if (scr == null) {
            stderr.printf("Unable to get the default screen.\n");
            return 1;
        }
        scr.force_update();
        windows = scr.get_windows();

        foreach (Wnck.Window win in windows) {
            if (!win.is_skip_tasklist()) {
                this.add(new AppButton(win, this.btnSize)); 
            }
        }
        scr.window_closed.connect(on_window_closed);
        scr.window_opened.connect(on_window_opened);
        return 0;
    }

    private void on_window_closed(Wnck.Window win) {
        foreach (Gtk.Widget widget in this.get_children()) {
            AppButton ab = (AppButton)widget;
            if (ab.xid == win.get_xid()) {
                this.remove(ab);
                this.show_all();
            }
        }
    }

    private void on_window_opened(Wnck.Window win) {
        if (!win.is_skip_tasklist()) {
            string desktop_file = GLib.Filename.display_basename(Bamf.Matcher.get_default().get_application_for_xid((uint32)win.get_xid()).get_desktop_file());
            bool matched = false;
            AppButton ab = null;
            print("DF: %s\n", desktop_file);
            foreach (Gtk.Widget widget in this.get_children()) {
                ab = (AppButton)widget;
                print("%s\n", ab.desktop_file);
                if (ab.desktop_file == desktop_file) {
                    matched = true;
                    ab.init_for_window(win, btnSize);
                    break;
                } 
            }
            if (!matched) {
                this.add(new AppButton(win, this.btnSize));
            }
            this.show_all();
        }
    }
}