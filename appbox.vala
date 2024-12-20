public class AppBox : Gtk.Box
{
    public string desktop_file { get; set; }
    private DesktopAppInfo _appInfo;

    public AppBox.with_button(AppButton button) {
        this.desktop_file = Bamf.Matcher.get_default().get_application_for_xid((uint32)button.xid).get_desktop_file();
        this.addButton(button);
    }

    public void addButton(AppButton button) {
        if ((this.desktop_file != "") && (this.desktop_file != null)) {
            this._appInfo = new GLib.DesktopAppInfo.from_filename(this.desktop_file);
        }
        button.appInfo = this._appInfo;
        this.add(button);
    }

    public AppButton getFirstChild() { 
        return (AppButton)this.get_children().nth_data(0);
    }

    public bool hasChildren() {
        if (this.get_children().length() == 0) {
            return false;
        }
        return true;
    }

    public uint getChildrenCount() {
        return this.get_children().length();
    }
}