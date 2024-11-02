public class WindowButton : Gtk.Button
{
    public WindowButton(Gdk.Pixbuf pb, int size) {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this.image = new Gtk.Image.from_pixbuf(pb.scale_simple(size, size, Gdk.InterpType.BILINEAR));
    }
}