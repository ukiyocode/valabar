public class TaskBar : Gtk.Box
{
    private List<AppButton> _launchers;

    public int init() {
        this._launchers = new List<AppButton>();

        foreach (Gtk.Widget child in this.get_children()) {
            /*AppBox abox = (AppBox)child;
            this._launchers.append(abox);
            abox.init_for_dfile();*/
            //this.remove(ab);
        }
        Wnck.Screen scr = Wnck.Screen.get_default ();
        if (scr == null) {
            stderr.printf("Unable to get the default screen.\n");
            return 1;
        }
        scr.force_update();

        unowned List<Wnck.Window> windows = scr.get_windows();
        foreach (Wnck.Window win in windows) {
            on_window_opened(win);
        }
        scr.window_closed.connect(on_window_closed);
        scr.window_opened.connect(on_window_opened);
        return 0;
    }

    private void on_window_closed(Wnck.Window win) {
        foreach (Gtk.Widget widget in this.get_children()) {
            AppBox abox = (AppBox)widget;
            foreach (Gtk.Widget child in abox.get_children()) {
                AppButton abutt = (AppButton)child;
                if (abutt.xid == win.get_xid()) {
                    /*foreach (AppButton ln in this._launchers) {
                        if ((ab.desktop_file == ln.desktop_file) && (ab.app.get_n_windows() == 0)) {
                            ab.init_for_dfile();
                            this.show_all();
                            return;
                        }
                    }*/
                    abox.remove(abutt);
                }
                if (abox.get_children().length() == 0) {
                    this.remove(abox);
                }
                this.show_all();
            }
        }
    }

    private void on_window_opened(Wnck.Window win) {
        if (!win.is_skip_tasklist()) {
            string desktop_file = GLib.Filename.display_basename(Bamf.Matcher.get_default().get_application_for_xid((uint32)win.get_xid()).get_desktop_file());
            foreach (Gtk.Widget widget in this.get_children()) {
                AppBox abox = (AppBox)widget;
                AppButton abutt = abox.getFirstChild();
                if (abox.desktop_file == desktop_file) {
                    if (!abutt.isRunning()) {
                        print("first win in app\n");
                        abutt.init_for_window(win);
                        this.show_all();
                        return;
                    } else {
                        print("new win for app\n");
                        abox.add(new AppButton(win));
                        this.show_all();
                        return;
                    }
                }
            }
            print("new app box\n");
            this.add(new AppBox(new AppButton(win))); 
            this.show_all();
        }
    }
}