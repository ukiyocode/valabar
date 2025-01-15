public class TaskBar : Gtk.Box, Gtk.Buildable
{
    private List<AppBox> launchers;
    private Bamf.Matcher matcher;

    public void parser_finished(Gtk.Builder builder) {
        this.launchers = new List<AppBox>();
        matcher = Bamf.Matcher.get_default();

        Gtk.Widget child = this.get_first_child();
        while (child != null) {
            AppBox abox = (AppBox)child;
            this.launchers.append(abox);
            abox.append(new AppButton.fromDesktopFile(abox.bamfApp.get_desktop_file()));
            child = child.get_next_sibling();
        }
        
        List<weak Bamf.Window> windows = matcher.get_windows();
        foreach (Bamf.Window win in windows) {
            on_window_opened(win);
        }
        /*unowned List<Wnck.Window> windows = scr.get_windows();
        foreach (Wnck.Window win in windows) {
            on_window_opened(win);
        }
        scr.window_closed.connect(on_window_closed);
        scr.window_opened.connect(on_window_opened);*/
    }

    /*private void on_window_closed(Wnck.Window win) {
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
    }*/

    private void on_window_opened(Bamf.Window win) {
        if (win.is_user_visible()) {
            //string desktop_file = matcher.get_application_for_xid(win.get_xid()).get_desktop_file();
            Bamf.Application bamfApp = matcher.get_application_for_xid(win.get_xid());
            //print("%s\n", desktop_file);
            Gtk.Widget child = this.get_first_child();
            while (child != null) {
                AppBox abox = (AppBox)child;
                AppButton abutt = (AppButton)abox.get_first_child();
                if (abox.bamfApp == bamfApp) {
                    print("name: %s\n", bamfApp.get_name());
                    /*if (!abutt.isRunning()) {
                        abutt.init_for_window(win);
                        //this.show_all(); queue_draw()??
                        return;
                    } else {
                        abox.addButton(new AppButton(win));
                        //this.show_all();
                        return;
                    }*/
                }
                child = child.get_next_sibling();
            }
            /*foreach (Gtk.Widget widget in this.get_children()) {
                AppBox abox = (AppBox)widget;
                AppButton abutt = abox.get_first_child();
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
            }*/
            this.append(new AppBox.with_button(new AppButton(win))); 
            //this.show_all();
        }
    }
}