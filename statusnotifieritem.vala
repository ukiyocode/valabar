public class StatusNotifierItem : Object {
    public signal void itemReady();
    public string? title { get; private set; }
    public string? iconName { get; private set; }
    public string? toolTip { get; private set; }
    private string? menuPath { get; private set; }
    private const string dBusInterface = "org.kde.StatusNotifierItem";
    private string busName;
    private string objectPath;
    DBusProxy sNIProxy;

    public StatusNotifierItem(string dBusPath) {
        this.title = null;
        this.iconName = null;
        string[] parts = dBusPath.split("/", 2);
        if (parts.length != 2) {
            error("Invalid input format in TrayChild.vala. Expected 'busName/objectPath'\n");
        }
        this.busName = parts[0];
        this.objectPath = "/"+parts[1];
        this.sNIProxy = null;
        getSNIProperties.begin(this.busName, this.objectPath, dBusInterface);
    }

    private async void getSNIProperties(string busName, string objectPath, string dBusInterface) {
        Variant? v;
        try {
            this.sNIProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, null, busName, objectPath, dBusInterface);
            v = this.sNIProxy.get_cached_property("Title");
            if (v != null) {
                this.title = v.get_string();
            }
            v = this.sNIProxy.get_cached_property("IconName");
            if (v != null) {
                this.iconName = v.get_string();
            }
            v = this.sNIProxy.get_cached_property("ToolTip");
            if (v != null) {
                VariantIter iter = v.iterator();
                string? s = null;
                iter.next("s");
                iter.next("a(iiay)");
                iter.next("s", out s);
                this.toolTip = s;
            } else {
                this.toolTip = this.title;
            }
            v = this.sNIProxy.get_cached_property("Menu");
            if (v != null) {
                this.menuPath = v.get_string();
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
        print("hhh\n");
        this.itemReady();
    }
}