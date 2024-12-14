[DBus (name = "org.kde.StatusNotifierWatcher")]
public interface StatusNotifierWatcher : Object
{
    /* Public methods */
    public abstract void RegisterStatusNotifierItem(string service) throws Error;
    public abstract void RegisterStatusNotifierHost(string service) throws Error;
    /* Public properties */
    public abstract string[] RegisteredStatusNotifierItems { owned get; }
    public abstract bool IsStatusNotifierHostRegistered { get; }
    public abstract int ProtocolVersion { get; }
    /* Signals */
    public signal bool StatusNotifierItemRegistered(string item);
    public signal bool StatusNotifierItemUnregistered(string item);
    public signal bool StatusNotifierHostRegistered();
}