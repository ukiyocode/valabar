class Clock : Gtk.ToggleButton, Gtk.Buildable {
    private uint timer;
    private DateTime current_time;
    private Gtk.Window parent_win;
    Gtk.Window calendar_win;

    public void parser_finished(Gtk.Builder builder) {
        parent_win = (Gtk.Window)this.get_toplevel();
        timer = Timeout.add(100, update_clock);
        this.toggled.connect(on_toggled);
    }

    private bool update_clock() {
        current_time = new DateTime.now_local();
        this.set_label(current_time.format("%H:%M"));
        uint seconds = 60 - current_time.get_second();
        timer = Timeout.add(seconds * 1000, update_clock);
        return false;
    }

    private void on_toggled() {
        if (this.get_active()) {
            calendar_win = new Gtk.Window(Gtk.WindowType.POPUP);
            calendar_win.set_default_size(180, 180);
            calendar_win.set_border_width(5);
            Gtk.Calendar calendar = new Gtk.Calendar();
            DateTime now = new DateTime.now_local();
            calendar.set_display_options(Gtk.CalendarDisplayOptions.SHOW_WEEK_NUMBERS
                                        | Gtk.CalendarDisplayOptions.SHOW_DAY_NAMES
                                        | Gtk.CalendarDisplayOptions.SHOW_HEADING);
            calendar.mark_day(now.get_day_of_month());
            calendar_win.add(calendar);
            calendar_win.set_type_hint(Gdk.WindowTypeHint.UTILITY);
            calendar_win.set_transient_for(parent_win);
            calendar_win.set_attached_to(parent_win);
            calendar_win.show_all();
            move_popup(calendar_win);
        } else {
            calendar_win.destroy();
            calendar_win = null;
        }
    }

    private void move_popup(Gtk.Window popup)
    {
        int x = 0;
        int y = 0;
        Gtk.Allocation pa;
        Gtk.Allocation a;
        popup.realize();
        popup.get_allocation(out pa);
 
        Gdk.Rectangle ext;
        popup.get_window().get_frame_extents(out ext);
        pa.width = ext.width;
        pa.height = ext.height;
  
        this.get_allocation(out a);
        this.get_window().get_origin(out x, out y);
        x += a.x;
        y += a.y;
        y-=pa.height;
        x-=(pa.width - this.get_allocated_width()) / 2;
        unowned Gdk.Monitor monitor = this.get_display().get_monitor_at_point(x,y);
        a = (Gtk.Allocation)monitor.get_workarea();
        x = x.clamp(a.x,a.x + a.width - pa.width);
        y = y.clamp(a.y,a.y + a.height - pa.height);
        popup.move(x, y);
    }
}