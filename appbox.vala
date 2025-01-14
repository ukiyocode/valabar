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
        this.append(button);
    }

    public bool hasChildren() {
        if (this.get_first_child() == null) {
            return false;
        }
        return true;
    }

    public uint getChildrenCount() {
        return this.observe_children().get_n_items();
        //return this.get_children().length();
    }
}