public class WindowButton : Gtk.Button
{
    private Wnck.Application app;
    public ulong xid { get; set; }

    public WindowButton(Wnck.Window ww, int size) {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this.app = ww.get_application();
        this.image = new Gtk.Image.from_pixbuf(app.get_icon().scale_simple(size, size, Gdk.InterpType.BILINEAR));
        this.set_tooltip_text(ww.get_name());
        this.xid = ww.get_xid();
    }
}