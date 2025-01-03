public class StatusNotifierItem : Object {
    public signal void itemReady();
    public string? title { get; private set; }
    public string? iconName { get; private set; }
    public string? toolTip { get; private set; }
    private string? menuPath;
    private string? activateName;
    private const string sNIInterface = "org.kde.StatusNotifierItem";
    private const int asyncWait = 2000;
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
    }

    public void activate() {
        this.sNIProxy.call.begin(this.activateName, new Variant("(ii)", 0, 0), DBusCallFlags.NONE, asyncWait);
    }

    private async DBusInterfaceInfo? getInterfaceInfo(string interfaceName) {
        try{
            DBusProxy introspectProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, null,
                this.busName, this.objectPath, "org.freedesktop.DBus.Introspectable");
            Variant xmlVariant = yield introspectProxy.call("Introspect", null, DBusCallFlags.NONE, asyncWait);
            string xmlData = "";
            if (xmlVariant.check_format_string("(s)", false)) {
                xmlVariant.get("(s)", out xmlData);
            }
            DBusNodeInfo dni = new DBusNodeInfo.for_xml(xmlData);
            return dni.lookup_interface(interfaceName);
        } catch (Error e) {
            error("Error in TrayChild.vala while introspecting: %s\n", e.message);
        }
    }

    public async void getSNIProperties() {
        Variant? v;
        DBusInterfaceInfo dii;
        try {
            dii = yield getInterfaceInfo(sNIInterface);
            this.sNIProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, this.busName, this.objectPath, sNIInterface);
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
            //DBusInterfaceInfo dii = this.sNIProxy.get_interface_info();
            DBusMethodInfo? dmi = dii.lookup_method("Activate");
            if (dmi == null) {
                dmi = dii.lookup_method("SecondaryActivate");
            }
            if (dmi != null) {
                this.activateName = dmi.name;
            } else {
                this.activateName = null;
                warning("Couldn't find activateName in getSNIProperties() in StatusNotifierItem");
            }
            this.itemReady();
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
    }
}