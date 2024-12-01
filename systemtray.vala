public class SystemTray : Gtk.Box, Gtk.Buildable
{
    private List<TrayChild> items;
    private NotifierHost notifierHost;

    public void parser_finished(Gtk.Builder builder) {
        items = new List<TrayChild>();
        notifierHost = new NotifierHost("org.kde.StatusNotifierWatcher");
        notifierHost.watcher_item_added.connect(on_item_added);
        //host.watcher_item_removed.connect(on_item_added);
        notifierHost.watcher_host_added.connect(on_host_added);
        this.show_all();
    }

    public void on_host_added() {
        string[] items = notifierHost.watcher_items();
        for (int i = 0; i < items.length; i++) {
            add_tray_child(items[i]);
        }
    }

    private void on_item_added(string id) {
        add_tray_child(id);
    }

    private void add_tray_child(string id) {
        TrayChild tc = new TrayChild(id);
        tc.props_gotten.connect((tc) => {
            this.add(tc);
            this.show_all();
        });
    }
    /*static Host host;
    ulong watcher_registration_handler;
    internal HashTable<string,unowned Item> items {get; private set;}
    public HashTable<string,Variant?> index_override {get; set;}
    public HashTable<string,Variant?> filter_override {get; set;}
    public bool symbolic_icons {get; set;}
    public bool show_application_status {get; set;}
    public bool show_communications {get; set;}
    public bool show_system {get; set;}
    public bool show_hardware {get; set;}
    public bool show_other {get; set;}
    public bool show_passive {get; set;}
    public int indicator_size {get; set;}
    public bool show_ayatana_labels {get; set;}
    internal signal void item_added(string id);
    internal signal void item_removed(string id);
    static construct
    {
        host = new Host("org.kde.StatusNotifierHost-itembox%d".printf(Gdk.CURRENT_TIME));
    }
    construct
    {
        items = new HashTable<string,unowned Item>(str_hash, str_equal);
        index_override = new HashTable<string,int>(str_hash,str_equal);
        filter_override = new HashTable<string,bool>(str_hash,str_equal);
        show_application_status = true;
        show_communications = true;
        show_system = true;
        show_hardware = true;
        show_passive = false;
        child_activated.connect((ch)=>{
            select_child(ch);
            (ch as Item).context_menu();
        });
        notify.connect((pspec)=>{
            if (pspec.name == "index-override")
                invalidate_sort();
            else
                invalidate_filter();
        });
        set_sort_func(sort_cb);
        set_filter_func(filter_cb);
        host.watcher_item_added.connect((item)=>{
            string[] np = item.split("/",2);
            if (!items.contains(item))
            {
                var snitem = new Item(np[0],(ObjectPath)("/"+np[1]));
                items.insert(item, snitem);
                this.add(snitem);
            }
        });
        host.watcher_item_removed.connect((item)=>{
            unowned Item child = items.lookup(item);
            if (child != null)
            {
                item_removed(child.id);
                child.destroy();
                items.remove(item);
            }
        });
        watcher_registration_handler = host.notify["watcher-registered"].connect(()=>{
            if (host.watcher_registered)
            {
                recreate_items();
                SignalHandler.disconnect(host,watcher_registration_handler);
            }
        });
        if (host.watcher_registered)
        {
            recreate_items();
            SignalHandler.disconnect(host,watcher_registration_handler);
        }
    }
    public ItemBox()
    {
        Object(orientation: Orientation.HORIZONTAL,
                selection_mode: SelectionMode.SINGLE,
                activate_on_single_click: true);
    }
    private void recreate_items()
    {
        string[] new_items = host.watcher_items();
        foreach (var item in new_items)
        {
            string[] np = item.split("/",2);
            if (!items.contains(item))
            {
                var snitem = new Item(np[0],(ObjectPath)("/"+np[1]));
                items.insert(item, snitem);
                this.add(snitem);
            }
        }
    }
    internal bool filter_cb(Gtk.FlowBoxChild ch)
    {
        unowned Item item = ch as Item;
        if (item.id != null && filter_override.contains(item.id))
            return filter_override.lookup(item.id).get_boolean();
        if (!show_passive && item.status == Status.PASSIVE) return false;
        if (show_application_status && item.cat == Category.APPLICATION) return true;
        if (show_communications && item.cat == Category.COMMUNICATIONS) return true;
        if (show_system && item.cat == Category.SYSTEM) return true;
        if (show_hardware && item.cat == Category.HARDWARE) return true;
        if (show_other && item.cat == Category.OTHER) return true;
        return false;
    }
    private int sort_cb(Gtk.FlowBoxChild ch1, Gtk.FlowBoxChild ch2)
    {
        unowned Item left = ch1 as Item;
        unowned Item right = ch2 as Item;
        int lpos = (int)left.ordering_index;
        int rpos = (int)right.ordering_index;
        if (left.id != null && index_override.contains(left.id))
            lpos = index_override.lookup(left.id).get_int32();
        if (right.id != null && index_override.contains(right.id))
            rpos = index_override.lookup(right.id).get_int32();
        return lpos - rpos;
    }
    internal int get_index(Item v)
    {
        var over_index = index_override.contains(v.id);
        int index = (int)v.ordering_index;
        if (over_index)
            index = index_override.lookup(v.id).get_int32();
        return index;
    }
    internal unowned Item? get_item_by_id(string id)
    {
        unowned Item? item = null;
        items.foreach((k,v)=>{
            if (v.id == id)
            {
                item = v;
                return;
            }
        });
        return item;
    }*/
}