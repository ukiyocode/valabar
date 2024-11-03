public class WindowButton : Gtk.Button
{
    private Wnck.Application app;
    private Wnck.Window ww;
    public ulong xid { get; set; }

    public WindowButton(Wnck.Window ww, int size) {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this.ww = ww;
        this.app = ww.get_application();
        this.image = new Gtk.Image.from_pixbuf(app.get_icon().scale_simple(size, size, Gdk.InterpType.BILINEAR));
        this.set_tooltip_text(ww.get_name());
        this.xid = ww.get_xid();
        this.clicked.connect(on_clicked);
    }

    private void on_clicked() {
        if (!ww.is_active()) {
            ww.activate(Gtk.get_current_event_time());           
        }
        else {
            ww.minimize();
        }
    }
}