public class TaskBar : Gtk.Box
{
    private List<AppButton> _launchers;

    public int init() {
        this._launchers = new List<AppButton>();

        foreach (Gtk.Widget child in this.get_children()) {
            AppButton ab = (AppButton)child;
            this._launchers.append(ab);
            //ab.init_for_dfile();
            this.remove(ab);
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
        /*foreach (Gtk.Widget widget in this.get_children()) {
            AppButton ab = (AppButton)widget;
            if (ab.xid == win.get_xid()) {
                foreach (AppButton ln in this._launchers) {
                    if ((ab.desktop_file == ln.desktop_file) && (ab.app.get_n_windows() == 0)) {
                        ab.init_for_dfile();
                        this.show_all();
                        return;
                    }
                }
                this.remove(ab);
                this.show_all();
            }
        }*/
    }

    private void on_window_opened(Wnck.Window win) {
        if (!win.is_skip_tasklist()) {
            string desktop_file = GLib.Filename.display_basename(Bamf.Matcher.get_default().get_application_for_xid((uint32)win.get_xid()).get_desktop_file());
            AppButton ab = null;
            foreach (Gtk.Widget widget in this.get_children()) {
                ab = (AppButton)((AppBox)widget).get_children().nth_data(0);
                if (ab.desktop_file == desktop_file) {
                    if (!ab.isRunning()) {
                        print("first win in app\n");
                        ab.init_for_window(win);
                        this.show_all();
                        return;
                    } else {
                        print("new win for app\n");
                        ab.parent.add(new AppButton(win));
                        this.show_all();
                        return;
                    }
                }
            }
            print("new app box\n");
            AppBox abox = new AppBox(); 
            abox.add(new AppButton(win));
            this.add(abox);
            this.show_all();
        }
    }
}