[DBus (name = "org.kde.StatusNotifierWatcher")]
public class StatusNotifierWatcher : Object
{
    public string[] RegisteredStatusNotifierItems {
        owned get {
            return watchedNamesIDs.get_keys_as_array();
        }
    }
    public bool IsStatusNotifierHostRegistered { get; }
    public int ProtocolVersion { get; }
    public signal bool StatusNotifierItemRegistered(string item);
    public signal bool StatusNotifierItemUnregistered(string item);
    public signal bool StatusNotifierHostRegistered();

    private const string snwPath = "/StatusNotifierWatcher";
    private uint owned_name;
    private HashTable<string, uint> watchedNamesIDs;

    public StatusNotifierWatcher() {
        this.watchedNamesIDs = new HashTable<string, uint>(str_hash, str_equal);
        try {
            this.RegisterStatusNotifierHost("org.kde.StatusNotifierWatcher");
        } catch(Error e) {
            error("Couldn't register notifier watcher: %s", e.message);
        }
    }

    public void RegisterStatusNotifierItem(string service, BusName sender) throws Error {
        string busName = (string)sender;
        string servicePath = busName + service;
        uint watchedNameID = 0;
    
        if (watchedNamesIDs.contains(servicePath)) {
            warning("Trying to register already registered item. Reregistering new...");
            watchedNamesIDs.remove(servicePath);
        }
        watchedNameID = Bus.watch_name(BusType.SESSION, busName, BusNameWatcherFlags.NONE,
            () => { //bus name appeared
                watchedNamesIDs.insert(servicePath, watchedNameID);
                this.StatusNotifierItemRegistered(servicePath);
            },
            () => { //bus name vanished
                removeWatchedItem(servicePath);
            }
        );
    }

    private void removeWatchedItem(string servicePath) {
        uint watchedNameID = 0;
        if (watchedNamesIDs.contains(servicePath)) {
            watchedNameID = watchedNamesIDs.get(servicePath);
            watchedNamesIDs.remove(servicePath);
            if (watchedNameID != 0) {
                Bus.unwatch_name(watchedNameID);
                this.StatusNotifierItemUnregistered(servicePath);
            }
        }
    }

    public void RegisterStatusNotifierHost(string service) throws Error {
        owned_name = Bus.own_name(BusType.SESSION, service, BusNameOwnerFlags.DO_NOT_QUEUE,
            null, //on_bus_acquired
            (connection) => { //on_name_acquired
                try {
                    connection.register_object(snwPath, this);
                    this.StatusNotifierHostRegistered();
                } catch (IOError e) {
                    error("Could not register StatusNotifierWatcher service: %s", e.message);
                }
            },
            () => { //on_name_lost
                error("Could not own \"org.kde.StatusNotifierWatcher\" name. Is there another system tray application running?");
            }
        );
    }

    ~StatusNotifierWatcher()
    {
        watchedNamesIDs.foreach((key, val) => {
            removeWatchedItem(key);
        });
        Bus.unown_name(owned_name);
    }
}