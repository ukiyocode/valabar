public class StatusNotifierWatcherProxy {
    private WatcherIface? watcher = null;
    private Watcher ww;

    public StatusNotifierWatcherProxy() {
        try {
            watcher = Bus.get_proxy_sync(BusType.SESSION, "org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher");

            // Connect to signals
            watcher.status_notifier_item_registered.connect((service) => {
                print("Status Notifier Item registered: %s\n", service);
            });

            watcher.status_notifier_item_unregistered.connect((service) => {
                print("Status Notifier Item unregistered: %s\n", service);
            });

            watcher.status_notifier_host_registered.connect(() => {
                print("Status Notifier Host registered\n");
            });

            watcher.status_notifier_host_unregistered.connect(() => {
                print("Status Notifier Host unregistered\n");
            });

        } catch(Error e) {
            error ("Could not connect to StatusNotifierWatcher: %s", e.message);
        }
    }
}