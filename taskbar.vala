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
            //abox.append(new AppButton.fromDesktopFile(abox.bamfApp.get_desktop_file()));
            abox.append(new AppButton.fromDesktopFile(abox.desktop_file));
            child = child.get_next_sibling();
        }
        
        List<weak Bamf.Window> windows = matcher.get_windows();
        foreach (Bamf.Window win in windows) {
            on_window_opened(win);
        }
        /*
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
            print("---------------------------------------------------------------------\n");
            Bamf.Application bamfApp = matcher.get_application_for_xid(win.get_xid());
            print("win name: %s\n", win.get_name());
            print("app name: %s\n", bamfApp.get_name());
            Gtk.Widget child = this.get_first_child();
            int ii = 0;
            while (child != null) {
                print("i: %i\n", ii);
                ii++;
                AppBox abox = (AppBox)child;
                print("namee: %s\n", abox.bamfApp.get_name());
                AppButton abutt = (AppButton)abox.get_first_child();
                if (abox.bamfApp.get_name() == bamfApp.get_name()) {
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
            this.append(new AppBox.with_button(new AppButton(win))); 
            //this.show_all();
        }
    }
}