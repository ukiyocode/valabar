class Volume : Gtk.ToggleButton, Gtk.Buildable {
    private Alsa.Mixer mixer;
    private Alsa.MixerElement master_element;
    private Alsa.SimpleElementId sid;

    public void parser_finished(Gtk.Builder builder) {
        this.events |= Gdk.EventMask.SCROLL_MASK;
        this.toggled.connect(on_toggled);
        this.scroll_event.connect(on_scroll);

        asound_initialize();
    }

    private void on_toggled() {
        if (this.get_active()) {
            
        } else {

        }
    }

    public bool on_scroll(Gdk.EventScroll event) {
        if (event.direction == Gdk.ScrollDirection.DOWN) {
            long vol = asound_get_volume() - 5;
            if (vol < 0) { vol = 0; }
            asound_set_volume(vol);
        }
        else if (event.direction == Gdk.ScrollDirection.UP) {
            long vol = asound_get_volume() + 5;
            if (vol > 100) { vol = 100; }
            asound_set_volume(vol);
        }
        return false;
    }
    
    bool asound_initialize()
    {
        Alsa.SimpleElementId.alloc(out sid);
        Alsa.Mixer.open(out mixer, 0);
        mixer.attach();
        mixer.register();
        mixer.load();

        for (master_element = mixer.first_elem(); master_element != null; master_element = master_element.next()) {
            master_element.get_id(sid);
            if (master_element.is_active() && sid.get_name() == "Master") {
                master_element.set_playback_volume_range(0, 100);
                return true;
            }
        }
        return false;
    }

    long asound_get_volume()
    {
        long aleft = 0;
        long aright = 0;
        if (master_element != null)
        {
            master_element.get_playback_volume(Alsa.SimpleChannelId.FRONT_LEFT, out aleft);
            master_element.get_playback_volume(Alsa.SimpleChannelId.FRONT_RIGHT, out aright);
        }
        return (aleft + aright) >> 1;
    }

    void asound_set_volume(long volume)
    {
        if (master_element != null)
        {
            master_element.set_playback_volume(Alsa.SimpleChannelId.FRONT_LEFT, volume);
            master_element.set_playback_volume(Alsa.SimpleChannelId.FRONT_RIGHT, volume);
        }
    }

    /*void asound_deinitialize()
    {
        if (mixer_evt_idle != 0) {
            Source.remove(mixer_evt_idle);
            mixer_evt_idle = 0;
        }

        for (var i = 0; i < num_channels; i++) {
            Source.remove(watches[i]);
            try
            {
                channels[i].shutdown(false);
            } catch (GLib.Error e){}
        }
        channels = {};
        watches = {};
        num_channels = 0;
        mixer = null;
        master_element = null;
        sid = null;
    }*/
}