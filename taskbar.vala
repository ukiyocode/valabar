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
            abox.append(new AppButton.fromDesktopFile(abox.desktop_file));
            child = child.get_next_sibling();
        }
        
        List<weak Bamf.Window> windows = matcher.get_windows();
        foreach (Bamf.Window win in windows) {
            on_window_opened(matcher, win);
        }
        matcher.view_opened.connect(on_window_opened);
        matcher.view_closed.connect(on_window_closed);
    }

    private void on_window_closed(Bamf.Matcher match, Bamf.View view) {
        if (view is Bamf.Window) {
            Bamf.Window win = (Bamf.Window)view;
            Gtk.Widget widget = this.get_first_child();
            while (widget != null) {
                AppBox abox = (AppBox)widget;
                Gtk.Widget child = abox.get_first_child();
                while (child != null) {
                    AppButton abutt = (AppButton)child;
                    if (abutt.xid == win.get_xid()) {
                        foreach (AppBox ln in this.launchers) {
                            if ((abox.desktop_file == ln.desktop_file) && (abox.getChildrenCount() == 1)) {
                                abutt.init_for_dfile(abox.desktop_file);
                                return;
                            }
                        }
                        abox.remove(abutt);
                        if (!abox.hasChildren()) {
                            this.remove(abox);
                        }
                    }
                    child = child.get_next_sibling();
                }
                widget = widget.get_next_sibling();
            }
        }
    }

    private void on_window_opened(Bamf.Matcher match, Bamf.View view) {
        if (view is Bamf.Window) {
            Bamf.Window win = (Bamf.Window)view;
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
                        if (!abutt.isRunning()) {
                            abutt.init_for_window(win);
                            //this.show_all(); queue_draw()??
                            return;
                        } else {
                            abox.addButton(new AppButton(win));
                            //this.show_all();
                            return;
                        }
                    }
                    child = child.get_next_sibling();
                }
                this.append(new AppBox.with_button(new AppButton(win))); 
                //this.show_all();
            }
        }
    }
}