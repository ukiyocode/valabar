[DBus (name = "org.kde.StatusNotifierWatcher")]
public interface NotifierWatcherIface: Object
{
    /* Signals */
    public signal void status_notifier_item_registered(string item);
    public signal void status_notifier_host_registered();
    public signal void status_notifier_item_unregistered(string item);
    public signal void status_notifier_host_unregistered();
    /* Public properties */
    public abstract string[] registered_status_notifier_items { owned get; }
    public abstract bool is_status_notifier_host_registered { get; }
    public abstract int protocol_version { get; }
    /* Public methods */
    public abstract void register_status_notifier_host(string service) throws Error;
}
[DBus (name = "org.kde.StatusNotifierWatcher")]
public class NotifierWatcher : Object
{
    /* Signals */
    public signal void status_notifier_item_registered(string item);
    public signal void status_notifier_host_registered();
    public signal void status_notifier_item_unregistered(string item);
    public signal void status_notifier_host_unregistered();
    /* Hashes */
    private HashTable<string,uint> name_watcher = new HashTable<string,uint>(str_hash, str_equal);
    private HashTable<string,uint> hosts = new HashTable<string,uint>(str_hash, str_equal);
    /* Public properties */
    public string[] registered_status_notifier_items { owned get { return get_registered_items(); } }
    public bool is_status_notifier_host_registered { get; private set; default = true; }
    public int protocol_version { get { return 0; } }
    /* Public methods */
    public void register_status_notifier_host(string service) throws Error
    {
        /* FIXME: Hosts management untested with non-ValaPanel hosts*/
        hosts.insert(service,Bus.watch_name(BusType.SESSION, service, BusNameWatcherFlags.NONE,
                (connection, name, name_owner) => {print("name: %s, namown: %s\n", name, name_owner);},
                () => {remove_host(service);}
                ));
        hosts.foreach ((key, val) => {
            print("key: %s, val: %u\n", key, val);
        });
        status_notifier_host_registered();
    }
    private void remove_host(string id)
    {
        uint name = hosts.lookup(id);
        hosts.remove(id);
        Bus.unwatch_name(name);
        status_notifier_host_unregistered();
    }
    private void remove(string id)
    {
        string outer = id.dup();
        uint name = name_watcher.lookup(id);
        if(name != 0)
            Bus.unwatch_name(name);
        name_watcher.remove(id);
        status_notifier_item_unregistered(outer);
        this.notify_property("registered-status-notifier-items");
        /* FIXME PropertiesChanged for RegisteredStatusNotifierItems*/
    }
    private string get_id(string name, string path)
    {
        return name + path;
    }
    private string[] get_registered_items()
    {
        var items_list = name_watcher.get_keys();
        string [] ret = {};
        foreach(var item in items_list)
            ret += item;
        return ret;
    }
    ~NotifierWatcher()
    {
        name_watcher.foreach((k,v)=>{Bus.unwatch_name(v);});
        hosts.foreach((k,v)=>{Bus.unwatch_name(v);});
    }
}