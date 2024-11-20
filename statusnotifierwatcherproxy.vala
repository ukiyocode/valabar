[DBus (name = "org.kde.StatusNotifierWatcher")]
public interface StatusNotifierWatcherInterface : Object {
    //public abstract string[] registered_status_notifier_items { get; }
    public abstract bool is_status_notifier_host_registered { get; }
    public abstract int protocol_version { get; }

    public abstract void register_status_notifier_item (string service) throws Error;
    public abstract void register_status_notifier_host (string service) throws Error;

    public signal void status_notifier_item_registered (string service);
    public signal void status_notifier_item_unregistered (string service);
    public signal void status_notifier_host_registered ();
    public signal void status_notifier_host_unregistered ();
}

public class StatusNotifierWatcherProxy {
    private StatusNotifierWatcherInterface? watcher_interface = null;

    public StatusNotifierWatcherProxy () {
        try {
            watcher_interface = Bus.get_proxy_sync (
                BusType.SESSION,
                "org.kde.StatusNotifierWatcher",
                "/StatusNotifierWatcher"
            );

            // Connect to signals
            watcher_interface.status_notifier_item_registered.connect ((service) => {
                print ("Status Notifier Item registered: %s\n", service);
            });

            watcher_interface.status_notifier_item_unregistered.connect ((service) => {
                print ("Status Notifier Item unregistered: %s\n", service);
            });

            watcher_interface.status_notifier_host_registered.connect (() => {
                print ("Status Notifier Host registered\n");
            });

            watcher_interface.status_notifier_host_unregistered.connect (() => {
                print ("Status Notifier Host unregistered\n");
            });

        } catch (Error e) {
            error ("Could not connect to StatusNotifierWatcher: %s", e.message);
        }
    }

    //  public void print_registered_items () {
    //      try {
    //          if (watcher_interface != null) {
    //              string[] items = watcher_interface.registered_status_notifier_items;
    //              print ("Registered Status Notifier Items:\n");
    //              foreach (string item in items) {
    //                  print (" - %s\n", item);
    //              }
    //          }
    //      } catch (Error e) {
    //          error ("Failed to get registered items: %s", e.message);
    //      }
    //  }

    public bool is_host_registered () {
        try {
            if (watcher_interface != null) {
                return watcher_interface.is_status_notifier_host_registered;
            }
        } catch (Error e) {
            error ("Failed to check host registration: %s", e.message);
        }
        return false;
    }

    public void register_item (string service) {
        try {
            if (watcher_interface != null) {
                watcher_interface.register_status_notifier_item (service);
            }
        } catch (Error e) {
            error ("Failed to register item: %s", e.message);
        }
    }
}