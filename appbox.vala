public class AppBox : Gtk.Box
{
    public string desktop_file { get; set; }
    private DesktopAppInfo _appInfo;

    public AppBox(AppButton button) {
        this.desktop_file = GLib.Filename.display_basename(Bamf.Matcher.get_default().get_application_for_xid((uint32)button.xid).get_desktop_file());
        if ((this.desktop_file != "") && (this.desktop_file != null)) {
            this._appInfo = new GLib.DesktopAppInfo(this.desktop_file);
        }
        button.appInfo = this._appInfo;
        this.add(button);
    }

    public AppButton getFirstChild() { 
        return (AppButton)this.get_children().nth_data(0);
    }

    public bool hasChildren()   {
        if (this.get_children().length() == 0) {
            return true;
        }
        return false;
    }
}