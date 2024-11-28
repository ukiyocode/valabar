class Clock : Gtk.ToggleButton, Gtk.Buildable {
    private uint timer;
    private DateTime current_time;
    private Gtk.Window parent_win;
    private Popup calendar_win;

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
            calendar_win = new Popup(this);
            Gtk.Calendar calendar = new Gtk.Calendar();
            DateTime now = new DateTime.now_local();
            calendar.set_display_options(Gtk.CalendarDisplayOptions.SHOW_WEEK_NUMBERS | Gtk.CalendarDisplayOptions.SHOW_DAY_NAMES |
                Gtk.CalendarDisplayOptions.SHOW_HEADING);
            calendar.mark_day(now.get_day_of_month());
            calendar_win.add(calendar);
            calendar_win.show_all();
        } else {
            calendar_win.destroy();
            calendar_win = null;
        }
    }
}