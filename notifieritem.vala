class NotifierItem {    
    private DBusProxy proxy;
    
    public NotifierItem(string itemId) {
        get_properties.begin(itemId, on_properties_gotten);
    }

    private void on_properties_gotten(Object? obj, AsyncResult res) {
        get_properties.end(res);
        if (res == null) {
            print("res is null\n");
            return;
        }
        print("res type: %s\n", res.get_type().name());
    }

    public async void get_properties(string item_path) {
        try {
            // Split the input path into bus name and object path
            string[] parts = item_path.split("/", 2);
            if (parts.length != 2) {
                stderr.printf("Invalid input format. Expected 'bus_name/object_path'\n");
                return;
            }

            string bus_name = parts[0];
            string object_path = "/" + parts[1];

            // Create DBus proxy
            proxy = yield new DBusProxy.for_bus(
                BusType.SESSION,
                DBusProxyFlags.NONE,
                null,
                bus_name,
                object_path,
                "org.kde.StatusNotifierItem",
                null
            );

            // Get all properties
            /*print_property("Category");
            print_property("Id");
            print_property("Title");
            print_property("Status");
            print_property("WindowId");
            print_property("IconName");
            print_property("IconPixmap");
            print_property("OverlayIconName");
            print_property("OverlayIconPixmap");
            print_property("AttentionIconName");
            print_property("AttentionIconPixmap");
            print_property("AttentionMovieName");
            print_property("ToolTip");
            print_property("ItemIsMenu");
            print_property("Menu");
            print_property("IconThemePath");*/

        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
    }

    private void print_property(string property_name) {
        Variant? value = proxy.get_cached_property(property_name);
        if (value != null) {
            stdout.printf("%s: %s\n", property_name, format_value(value));
        } else {
            stdout.printf("%s: <not available>\n", property_name);
        }
    }

    private string format_value(Variant value) {
        if (value.is_of_type(new VariantType("(iiay)"))) {
            // Handle IconPixmap type
            return "<IconPixmap data>";
        } else if (value.is_of_type(new VariantType("a(iiay)"))) {
            return "<Array of IconPixmap data>";
        } else if (value.is_of_type(new VariantType("(sa(iiay)ss)"))) {
            // Handle ToolTip type
            return "<ToolTip data>";
        } else {
            return value.print(true);
        }
    }

    /*public static int main(string[] args) {
        if (args.length != 2) {
            stderr.printf("Usage: %s <StatusNotifierItem_Id>\n", args[0]);
            stderr.printf("Example: %s :1.80/org/ayatana/NotificationItem/Onboard\n", args[0]);
            return 1;
        }

        var loop = new MainLoop();
        var props = new StatusNotifierItemProperties();

        props.get_properties.begin(args[1], (obj, res) => {
            try {
                props.get_properties.end(res);
            } catch (Error e) {
                stderr.printf("Error: %s\n", e.message);
            }
            loop.quit();
        });

        loop.run();
        return 0;
    }*/
}