public class TaskBar : Gtk.Box
{
    private Wnck.Screen scr;
    private unowned List<Wnck.Window> windows;
    public int btn_size { get; set; }

    public int init_() {
        scr = Wnck.Screen.get_default ();
        if (scr == null) {
            stderr.printf("Unable to get the default screen.\n");
            return 1;
        }
        scr.force_update();
        windows = scr.get_windows();

        foreach (Wnck.Window win in windows) {
            if (win.get_window_type() == Wnck.WindowType.NORMAL) {
                this.add(new WindowButton(win, btn_size)); 
            }
        }
        scr.window_closed.connect(on_window_closed);
        scr.window_opened.connect(on_window_opened);
        return 0;
    }

    private void foreach_remove_callback(WindowButton wb, Wnck.Window ww){
        if (wb.xid == ww.get_xid()) {
            this.remove(wb);
            this.show_all();
        }
    }
    private void on_window_closed(Wnck.Window win) {
        this.foreach ((elem) => foreach_remove_callback((WindowButton)elem, win));
    }

    private void on_window_opened(Wnck.Window win) {
        if (win.get_window_type() == Wnck.WindowType.NORMAL) {
            this.add(new WindowButton(win, btn_size));
            this.show_all();
        }
    }
/*
    public override void add (Gtk.Widget widget) {
        widget.set_parent(this);
        this.queue_resize();*?
        //this._child = widget;
    }

    public override void remove (Gtk.Widget widget) {
        if (this.)
        widget.unparent();
        widget = null;
        if (this.get_visible () && widget.get_visible ()) {
            this.queue_resize_no_redraw ();
        }
        //this.queue_resize();
    }*/
/*
    public override void forall_internal (bool include_internals, Gtk.Callback callback) {
        base.forall_internal(include_internals, callback);
        /*List<weak Gtk.Widget> chlds = this.get_children();
        foreach (Gtk.Widget widg in chlds) {
            if (widg != null) {
                callback(widg);
            }
        }
    }

    /*public override Gtk.SizeRequestMode get_request_mode () {
        return this._child.get_request_mode ();
    }*/

    //  public Gtk.Widget get_child () {
    //      return this._child;
    //  }
}