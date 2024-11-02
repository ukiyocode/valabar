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
        Wnck.Application app;
        Gtk.Button btn;
        Gdk.Pixbuf pb;

        foreach (Wnck.Window wnd in wnds) {
            if (wnd.get_window_type() == Wnck.WindowType.NORMAL) {
                //stdout.printf("%s\n", wnd.get_name());
                //stdout.printf("%lu\n", wnd.get_xid());
                //stdout.printf("%s\n", wnd.get_window_type().to_string());
                app = wnd.get_application();
                btn = new Gtk.Button();
                btn.halign = Gtk.Align.START;
                btn.valign = Gtk.Align.CENTER;
                pb = app.get_icon();
                pb = pb.scale_simple(30, 30, Gdk.InterpType.BILINEAR);
                btn.image = new Gtk.Image.from_pixbuf(pb);
                this.add(btn); 
            }
        }
    }
}