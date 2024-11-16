public class TaskBar : Gtk.Box
{
    private List<AppBox> _launchers;

    public int init() {
        this._launchers = new List<AppBox>();

        foreach (Gtk.Widget child in this.get_children()) {
            AppBox abox = (AppBox)child;
            this._launchers.append(abox);
            abox.add (new AppButton.fromDesktopFile(abox.desktop_file));
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
                    foreach (AppBox ln in this._launchers) {
                        if ((abox.desktop_file == ln.desktop_file) && (abox.getChildrenCount() == 1)) {
                            abutt.init_for_dfile(abox.desktop_file);
                            this.show_all();
                            return;
                        }
                    }
                    abox.remove(abutt);
                    this.show_all();
                    if (!abox.hasChildren()) {
                        this.remove(abox);
                    }
                    this.show_all();
                }
            }
        }
    }

    private void on_window_opened(Wnck.Window win) {
        if (!win.is_skip_tasklist()) {
            string desktop_file = Bamf.Matcher.get_default().get_application_for_xid((uint32)win.get_xid()).get_desktop_file();
            foreach (Gtk.Widget widget in this.get_children()) {
                AppBox abox = (AppBox)widget;
                AppButton abutt = abox.getFirstChild();
                if (abox.desktop_file == desktop_file) {
                    if (!abutt.isRunning()) {
                        abutt.init_for_window(win);
                        this.show_all();
                        return;
                    } else {
                        abox.addButton(new AppButton(win));
                        this.show_all();
                        return;
                    }
                }
            }
            this.add(new AppBox(new AppButton(win))); 
            this.show_all();
        }
    }
}