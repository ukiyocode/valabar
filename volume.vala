class Volume : Gtk.ToggleButton, Gtk.Buildable {
    private Alsa.Mixer mixer;
    private Alsa.MixerElement master_element;
    private Alsa.SimpleElementId sid;
    private uint[] watches;
    private IOChannel[] channels;
    private Gtk.Box buttonBox;
    private Gtk.Label buttonLabel;
    private Gtk.Image buttonImage;

    PulseAudio.MainLoop pulseLoop;
    PulseAudio.Context pulseContext;
    IOChannel pulseChannel;

    public void parser_finished(Gtk.Builder builder) {
        this.events |= Gdk.EventMask.SCROLL_MASK;
        this.toggled.connect(on_toggled);
        this.scroll_event.connect(on_scroll);
        this.buttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);

        asound_initialize();
        this.buttonLabel = new Gtk.Label("");
        this.buttonImage = new Gtk.Image();
        this.buttonBox.add(this.buttonLabel);
        this.buttonBox.add(this.buttonImage);
        this.add(buttonBox);
        //  this.pulseLoop = new PulseAudio.MainLoop();
        //this.pulseChannel = new IOChannel.unix_new(new Posix.pollfd().fd);
        //this.pulseLoop.set_poll_func(pulseChannel);
        //  this.pulseContext = new PulseAudio.Context(pulseLoop.get_api(), null);
        //  this.pulseContext.set_state_callback(on_pulse_state);
        //  if (this.pulseContext.connect(null, PulseAudio.Context.Flags.NOFAIL, null) < 0) {
        //      print( "pa_context_connect() failed: %s\n", PulseAudio.strerror(pulseContext.errno()));
        //  }
        //pulseContext.get_sink_info_list(on_sink_info);
    }

    private void on_pulse_state(PulseAudio.Context c) {
        print("%s\n", c.get_state().to_string());
    }
    private void on_sink_info(PulseAudio.Context c, PulseAudio.SinkInfo? i, int eol) {
        print("sink\n");
    } 

    private void updateButton(long curVolume) {
        string imgPath = ValaBar.exePath;

        if (curVolume == 0) {
            imgPath += "/images/audio-volume-muted-symbolic.svg";
        } else if (curVolume <= 30) {
            imgPath += "/images/audio-volume-low-symbolic.svg";
        } else if (curVolume < 70) {
            imgPath += "/images/audio-volume-medium-symbolic.svg";
        } else {
            imgPath += "/images/audio-volume-high-symbolic.svg";
        }
        this.buttonLabel.label = curVolume.to_string()+"%";
        
        if (imgPath != this.buttonImage.file) {
            this.buttonBox.remove(this.buttonImage);
            this.buttonImage = new Gtk.Image.from_file(imgPath);
            this.buttonBox.add(this.buttonImage);
        }
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

        bool meFound = false;
        for (master_element = mixer.first_elem(); master_element != null; master_element = master_element.next()) {
            master_element.get_id(sid);
            if (master_element.is_active() && sid.get_name() == "Master") {
                master_element.set_playback_volume_range(0, 100);
                meFound = true;
                break;
            }
        }
        if (!meFound) {
            return false;
        }
        
        int n_fds = mixer.poll_descriptors_count();
        Posix.pollfd[] fds = new Posix.pollfd[n_fds];

        channels = new IOChannel[n_fds];
        watches = new uint[n_fds];
        mixer.poll_descriptors(fds);
        for (var i = 0; i < n_fds; ++i)
        {
            IOChannel channel = new IOChannel.unix_new(fds[i].fd);
            watches[i] = channel.add_watch(IOCondition.IN, asound_mixer_event);
            channels[i] = channel;
        }
        return true;
    }

    bool asound_mixer_event(IOChannel channel, IOCondition cond)
    {
        mixer.handle_events();
        updateButton(asound_get_volume());

        return true;
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
            updateButton(volume);
        }
    }
}