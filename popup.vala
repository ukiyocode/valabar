class Popup : Gtk.Window {
    private Gtk.Widget parent_widget;
    private Gtk.Window parent_window;

    public Popup(Gtk.Widget parent_widget) {
        Object(type: Gtk.WindowType.POPUP);
        this.parent_widget = parent_widget;
        this.parent_window = (Gtk.Window)parent_widget.get_toplevel();
        this.set_default_size(100, 100);
        this.set_type_hint(Gdk.WindowTypeHint.UTILITY);
        this.set_transient_for(parent_window);
        this.set_attached_to(parent_window);
    }

    public void adjustPosition()
    {
        int x = 0;
        int y = 0;
        Gtk.Allocation pa;
        Gtk.Allocation a;
        Gdk.Rectangle ext;

        this.realize();
        this.get_allocation(out pa);      
        this.get_window().get_frame_extents(out ext);
        pa.width = ext.width;
        pa.height = ext.height;
  
        parent_widget.get_allocation(out a);
        parent_widget.get_window().get_origin(out x, out y);
        x += a.x;
        y += a.y;
        y-=pa.height;
        x-=(pa.width - parent_widget.get_allocated_width()) / 2;
        unowned Gdk.Monitor monitor = parent_widget.get_display().get_monitor_at_point(x,y);
        a = (Gtk.Allocation)monitor.get_workarea();
        x = x.clamp(a.x,a.x + a.width - pa.width);
        y = y.clamp(a.y,a.y + a.height - pa.height);
        this.move(x, y);
    }

    public override void show_all() {
        base.show_all();
        adjustPosition();
    } 
}