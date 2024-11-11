public class WindowButton : Gtk.Button
{
    private Wnck.Application app;
    public Wnck.Window window { get; }
    public ulong xid { get; set; }

    public WindowButton(Wnck.Window window, int size) {
        this.halign = Gtk.Align.START;
        this.valign = Gtk.Align.CENTER;
        this._window = window;
        this.app = window.get_application();
        this.image = new Gtk.Image.from_pixbuf(app.get_icon().scale_simple(size, size, Gdk.InterpType.BILINEAR));
        this.set_tooltip_text(window.get_name());
        this.xid = window.get_xid();
        this.button_press_event.connect(on_button_press);
    }       

    private bool on_mitem_close(Gtk.Widget widget, Gdk.EventButton event) {
        Gtk.Menu parent_menu = (Gtk.Menu)widget.parent;
        WindowButton wb = (WindowButton)parent_menu.get_attach_widget();
        wb.window.close(Gtk.get_current_event_time());
        return false;
    }

    private bool on_button_press(Gtk.Widget widget, Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS)
        {
            WindowButton wb = (WindowButton)widget;
            if (event.button == 1) { //left button
                if (!wb.window.is_active()) {
                    wb.window.activate(Gtk.get_current_event_time());           
                }
                else {
                    wb.window.minimize();
                }
                return true;
            } else if ((event.button == 3) && event.triggers_context_menu()) { //right button
                Gtk.Menu menu = new Gtk.Menu();
                Gtk.MenuItem mitem_close = new Gtk.MenuItem.with_label("Close");
                mitem_close.button_release_event.connect(on_mitem_close);
                menu.deactivate.connect(menu.destroy);
                menu.attach_to_widget(widget, null);
                menu.add(mitem_close);
                menu.show_all ();
                menu.popup_at_widget (widget, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, event);
            }
        }
        return false;
    }
}