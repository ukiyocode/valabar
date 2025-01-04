public class StatusNotifierItem : Object {
    public signal void itemReady();
    public string? title { get; private set; }
    public string? iconName { get; private set; }
    public string? toolTip { get; private set; }
    public Variant menuLayout { get; private set; }
    private string? menuPath;
    private string? activateName;
    private const string sNIInterface = "org.kde.StatusNotifierItem";
    private const string dbusMenuInterface = "com.canonical.dbusmenu";
    private const int dBusWait = 2000;
    public string busName { get; private set; }
    public string objectPath { get; private set; }
    private DBusProxy sNIProxy;
    private DBusProxy menuProxy;

    public StatusNotifierItem(string dBusPath) {
        this.title = null;
        this.iconName = null;
        this.toolTip = null;
        this.menuLayout = null;
        this.menuPath = null;
        this.activateName = null;
        string[] parts = dBusPath.split("/", 2);
        if (parts.length != 2) {
            error("Invalid input format in TrayChild.vala. Expected 'busName/objectPath'");
        }
        this.busName = parts[0];
        this.objectPath = "/"+parts[1];
        this.sNIProxy = null;
        this.menuProxy = null;
    }

    public void activate() {
        if (sNIProxy == null) {
            warning("sNIProxy is null while running activate function in StatusNotifierItem");
            return;
        }
        if (this.activateName != null) {
            this.sNIProxy.call.begin(this.activateName, new Variant("(ii)", 0, 0), DBusCallFlags.NONE, dBusWait);
        }
    }

    public void menuItemClicked(int32 id) {
        if (menuProxy == null) {
            warning("menuProxy is null while running menuItemClicked function in StatusNotifierItem");
            return;
        }
        this.menuProxy.call.begin("Event", new Variant ("(isvu)", id, "clicked", new Variant.string(""), Gtk.get_current_event_time()), DBusCallFlags.NONE, dBusWait);
    }

    private async DBusInterfaceInfo? getInterfaceInfo(string objectPath, string interfaceName) {
        try{
            DBusProxy introspectProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, null,
                this.busName, objectPath, "org.freedesktop.DBus.Introspectable");
            Variant xmlVariant = yield introspectProxy.call("Introspect", null, DBusCallFlags.NONE, dBusWait);
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

    private async void getMenuLayout() {
        DBusInterfaceInfo dii = yield getInterfaceInfo(this.menuPath, dbusMenuInterface);

        try {
            this.menuProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, this.busName, this.menuPath, dbusMenuInterface);
            DBusMethodInfo? dmi = dii.lookup_method("GetLayout");
            if (dmi != null) {
                this.menuLayout = yield this.menuProxy.call("GetLayout", new Variant ("(ii^as)", 0, -1, new string[0]), DBusCallFlags.NONE, dBusWait);
                VariantIter iter = this.menuLayout.iterator();
                iter.next("u");
                this.menuLayout = iter.next_value();
                this.menuProxy.g_signal.connect((sender_name, signal_name) => {
                    if (signal_name == "LayoutUpdated") {
                        getMenuLayout.begin();
                    }
                });
            }
        } catch (Error e) {
            error("Error in TrayChild.vala while getting dbusMenu: %s\n", e.message);
        }
    }

    private void onSNISignal(string? sender_name, string signal_name, Variant parameters) {
        if ((signal_name == "NewIcon") || (signal_name == "NewToolTip")) {
            this.getSNIProperties.begin(false);
        }
    }

    public async void getSNIProperties(bool updateMenu) {
        Variant? v;
        DBusInterfaceInfo dii;
        try {
            dii = yield getInterfaceInfo(this.objectPath, sNIInterface);
            this.sNIProxy = yield new DBusProxy.for_bus(BusType.SESSION, DBusProxyFlags.NONE, dii, this.busName, this.objectPath, sNIInterface);
            this.sNIProxy.g_signal.connect(onSNISignal);
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
            if ((v != null) && (updateMenu)) {
                this.menuPath = v.get_string();
                yield this.getMenuLayout();
            }
            this.activateName = null;
            //DBusInterfaceInfo dii = this.sNIProxy.get_interface_info();
            DBusMethodInfo? dmi = dii.lookup_method("Activate");
            if (dmi == null) {
                dmi = dii.lookup_method("SecondaryActivate");
            }
            if (dmi != null) {
                this.activateName = dmi.name;
            } else {
                warning("Couldn't find activateName in getSNIProperties() in StatusNotifierItem");
            }
            this.itemReady();
        } catch (Error e) {
            error("Error in TrayChild.vala while getting StatusNotifierItem properties: %s\n", e.message);
        }
    }
}