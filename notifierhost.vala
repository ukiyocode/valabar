public class NotifierHost: Object
{
    public string object_path {private get; construct;}
    public bool watcher_registered {get; private set;}
    private NotifierWatcher nested_watcher;
    private NotifierWatcherIface outer_watcher;
    private uint owned_name;
    private uint watched_name;
    private bool is_nested_watcher;
    public signal void watcher_item_added(string id);
    public signal void watcher_item_removed(string id);
    public signal void watcher_host_added();
    public NotifierHost(string path)
    {
        Object(object_path: path);
    }
    public string[] watcher_items()
    {
        if (is_nested_watcher)
            return nested_watcher.registered_status_notifier_items;
        else
        {
            NotifierWatcherIface? outer = null;
            try
            {
                outer = Bus.get_proxy_sync(BusType.SESSION,"org.kde.StatusNotifierWatcher","/StatusNotifierWatcher");
            } catch (Error e) {stderr.printf("%s\n",e.message);}
            return (outer != null) ? outer.registered_status_notifier_items : outer_watcher.registered_status_notifier_items;
        }
    }
    private void on_bus_aquired(DBusConnection conn)
    {
        try {
            nested_watcher = new NotifierWatcher();
            nested_watcher.status_notifier_host_registered.connect(() => { watcher_host_added(); });
            nested_watcher.status_notifier_item_registered.connect((id) => { watcher_item_added(id); });
            nested_watcher.status_notifier_item_unregistered.connect((id) => { watcher_item_removed(id); });
            conn.register_object ("/StatusNotifierWatcher", nested_watcher);
            nested_watcher.register_status_notifier_host(object_path);
        } catch (Error e) {
            stderr.printf ("Could not register service. Waiting for external watcher\n");
        }
    }
    private void create_nested_watcher()
    {
        owned_name = Bus.own_name (BusType.SESSION, "org.kde.StatusNotifierWatcher", BusNameOwnerFlags.NONE,
            on_bus_aquired,
            () => {
                print("nest\n");
                watcher_registered = true;
                is_nested_watcher = true;
            },
            () => {
                print("out\n");
                is_nested_watcher = false;
                create_out_watcher();
            });
    }
    private void create_out_watcher()
    {
        try{
            outer_watcher = Bus.get_proxy_sync(BusType.SESSION,"org.kde.StatusNotifierWatcher","/StatusNotifierWatcher");
            outer_watcher.status_notifier_host_registered.connect(() => { watcher_host_added(); });
            outer_watcher.status_notifier_item_registered.connect((id) => { watcher_item_added(id); });
            outer_watcher.status_notifier_item_unregistered.connect((id) => { watcher_item_removed(id); });
            watched_name = Bus.watch_name(BusType.SESSION,"org.kde.StatusNotifierWatcher",GLib.BusNameWatcherFlags.NONE,
                                                    () => {
                                                        nested_watcher = null;
                                                        is_nested_watcher = false;
                                                        watcher_registered = true;
                                                        },
                                                    () => {
                                                        Bus.unwatch_name(watched_name);
                                                        is_nested_watcher = true;
                                                        create_nested_watcher();
                                                        }
                                                    );
            outer_watcher.register_status_notifier_host(object_path);
        } catch (Error e) {
            stderr.printf("%s\n",e.message);
            return;
        }
    }
    construct
    {
        is_nested_watcher = true;
        watcher_registered = false;
        create_nested_watcher();
    }
    ~NotifierHost()
    {
        if (is_nested_watcher)
            Bus.unown_name(owned_name);
        else
            Bus.unwatch_name(watched_name);
    }
}