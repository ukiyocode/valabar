public class WMIcon : Object
{
    public Gtk.Image iconImage { get; construct set; }
    private string iconName;

    public WMIcon(ulong xid) {
        print("Xid: %lu\n", xid);
        iconName = "image-missing-symbolic";
        iconImage = new Gtk.Image.from_icon_name(iconName);

        var disp = Gdk.Display.get_default();
        print("disp: %s\n", disp.get_type().name());
    }
}