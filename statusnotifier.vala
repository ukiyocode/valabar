private struct Argb32 {
    int a;
    int b;
    uint8[] c;
}

private struct ToolTipStruct {
    string iconName;
    Argb32[] iconData;
    string title;
    string description;
}

[DBus (name = "org.kde.StatusNotifierItem")]
private interface StatusNotifierItemIface : Object
{
    public abstract string? Category { owned get; }
    public abstract string? Id { owned get; }
    public abstract string? Title { owned get; }
    public abstract string? Status { owned get; }
    public abstract uint32? WindowId { owned get; }
    public abstract string? IconName { owned get; }
    public abstract Argb32[] IconPixmap { owned get; }
    public abstract string? OverlayIconName { owned get; }
    public abstract Argb32[] OverlayIconPixmap { owned get; }
    public abstract string? AttentionIconName { owned get; }
    public abstract Argb32[] AttentionIconPixmap { owned get; }
    public abstract string? AttentionMovieName { owned get; }
    public abstract ToolTipStruct? ToolTip { owned get; }
    public abstract bool? ItemIsMenu { owned get; }
    public abstract ObjectPath Menu { owned get; }

    public abstract void ContextMenu(int x, int y);
    public abstract void Activate(int x, int y);
    public abstract void SecondaryActivate(int x, int y);
    public abstract void Scroll(int delta, string orientation);

    public signal void NewTitle();
    public signal void NewIcon();
    public signal void NewAttentionIcon();
    public signal void NewOverlayIcon();
    public signal void NewToolTip();
    public signal void NewStatus(string status);
}

[DBus (name = "org.kde.StatusNotifierWatcher")]
public class StatusNotifierWatcher : Object
{
    public string[] RegisteredStatusNotifierItems { owned get; }
    public bool IsStatusNotifierHostRegistered { get; }
    public int ProtocolVersion { get; }
    public signal bool StatusNotifierItemRegistered(string item);
    public signal bool StatusNotifierItemUnregistered(string item);
    public signal bool StatusNotifierHostRegistered();
    
    private const string snwIface = "org.kde.StatusNotifierWatcher";
    private const string snwPath = "/StatusNotifierWatcher";
    private uint owned_name;
    private HashTable<string, uint> watchedNamesIDs = new HashTable<string, uint>(str_hash, str_equal);

    public void RegisterStatusNotifierItem(string service, BusName sender) throws Error {
        string busName = (string)sender;
        uint watchedNameID = 0;
    
        if (watchedNamesIDs.contains(service)) {
            warning("Trying to register already registered item. Reregistering new...");
            watchedNamesIDs.remove(service);
        }
        watchedNameID = Bus.watch_name(BusType.SESSION, busName, BusNameWatcherFlags.NONE,
            () => { //bus name appeared
                watchedNamesIDs.insert(service, watchedNameID);
                try {
                    StatusNotifierItemIface notifierItem = Bus.get_proxy_sync(BusType.SESSION, busName, service);
                    if (notifierItem.Id == null) print("null\n"); else
                        print("id: %s\n", notifierItem.Id);
                    /*ping_iface.notify.connect((pspec)=>{
                        if (ping_iface.id == null ||
                        ping_iface.title == null ||
                        ping_iface.id.length <= 0 ||
                        ping_iface.title.length <= 0)
                            remove(get_id(name,path)); });*/
                } catch (Error e) {
                    //remove(get_id(name,path));
                }
            },
            () => { //bus name vanished
                watchedNamesIDs.remove(service);
                Bus.unwatch_name(watchedNamesIDs.get(service));
            }
            //() => {remove(get_id(name,path));}
        );
        //name_watcher.insert(id,name_handler);
        StatusNotifierItemRegistered(service);
        print("item: %s\n", service);
    }

    private void onNameVanished(DBusConnection connection, string name) {
        print("Vanished\n");
    }

    public void RegisterStatusNotifierHost(string service) throws Error {
        owned_name = Bus.own_name(BusType.SESSION, snwIface, BusNameOwnerFlags.DO_NOT_QUEUE, on_bus_acquired, on_name_acquired, on_name_lost);
    }

    private void on_bus_acquired(DBusConnection connection, string name) {
    }

    private void on_name_acquired(DBusConnection connection, string name) {
        try {
            connection.register_object(snwPath, new StatusNotifierWatcher());
            StatusNotifierHostRegistered();
        } catch (IOError e) {
            error("Could not register StatusNotifierWatcher service: %s\n", e.message);
        }
    }

    private void on_name_lost(DBusConnection connection, string name) {
        print("lost\n");
    }

    ~StatusNotifierWatcher()
    {
        Bus.unown_name(owned_name);
        watchedNamesIDs.foreach((key, val) => {
            watchedNamesIDs.remove(key);
            Bus.unwatch_name(val);
        });
    }
}