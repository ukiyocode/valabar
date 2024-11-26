/*[Compact]
[CCode (cprefix = "snd_mixer_", cname = "snd_mixer_t", free_function = "snd_mixer_close")]
public class Mixer
{
    public extern static int open (out Mixer mixer, int t = 0);
    public extern int attach (string card = "default");
    public extern int detach (string card = "default");
    public extern uint get_count ();
    public extern int load ();

    [CCode (cname = "snd_mixer_selem_register")]
    public extern int register (Alsa.MixerRegistrationOptions? options = null, out Alsa.MixerClass classp = null );

    public extern Alsa.MixerElement first_elem ();
    public extern Alsa.MixerElement last_elem ();
}*/

class Volume : Gtk.ToggleButton, Gtk.Buildable {
    private Alsa.Mixer mixer;
    private Alsa.MixerElement master_element;
    private Alsa.SimpleElementId sid;
    private Alsa.PcmDevice pcmDev;
    private uint[] watches;
    private IOChannel[] channels;
    private Gtk.Box contBox;
    private Gtk.Image img;
    private Gtk.Label lbl;
    private uint mixer_evt_idle;

    public void parser_finished(Gtk.Builder builder) {
        this.events |= Gdk.EventMask.SCROLL_MASK;
        this.toggled.connect(on_toggled);
        this.scroll_event.connect(on_scroll);

        asound_initialize();
        Gtk.Box contBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        string imgPath = "";
        long curVolume = asound_get_volume();
        if (curVolume == 0) {
            imgPath = "/images/audio-volume-muted-symbolic.svg";
        } else if (curVolume <= 30) {
            imgPath = "/images/audio-volume-low-symbolic.svg";
        } else if (curVolume < 70) {
            imgPath = "/images/audio-volume-medium-symbolic.svg";
        } else {
            imgPath = "/images/audio-volume-high-symbolic.svg";
        }
        this.img = new Gtk.Image.from_file(ValaBar.exePath + imgPath);
        this.lbl = new Gtk.Label(curVolume.to_string()+"%");
        contBox.add(this.lbl);
        contBox.add(this.img);
        this.add(contBox);
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

    /*int snd_mixer_poll_descriptors_count 	( 	snd_mixer_t *  	mixer	) 	
    [CCode(cname = "FOO", cheader_filename = "blah.h")]
    public extern void foo();*/


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
        print("%i\n", n_fds);
        Posix.pollfd[] fds = new Posix.pollfd[n_fds];

        channels = new IOChannel[n_fds];
        watches = new uint[n_fds];
        //num_channels = n_fds;

        mixer.poll_descriptors(fds);
        for (var i = 0; i < n_fds; ++i)
        {
            var channel = new IOChannel.unix_new(fds[i].fd);
            watches[i] = channel.add_watch(IOCondition.IN, asound_mixer_event);
            channels[i] = channel;
        }
        /*Alsa.PcmDevice defCard;
        Alsa.PcmDevice.open(out defCard, "hw:1", Alsa.PcmStream.PLAYBACK, 0);
        int n_fds = defCard.get_poll_descriptors_count();
        Posix.pollfd[] fds = new Posix.pollfd[n_fds];

        channels = new IOChannel[n_fds];
        watches = new uint[n_fds];

        defCard.set_poll_descriptors(fds);
        for (var i = 0; i < n_fds; ++i)
        {
            var channel = new IOChannel.unix_new(fds[i].fd);
            watches[i] = channel.add_watch(IOCondition.IN, asound_mixer_event);
            channels[i] = channel;
        }*/
        return true;
    }

    bool asound_mixer_event(IOChannel channel, IOCondition cond)
    {
        print("%i\n", mixer.handle_events());
        /*int res = 0;
        if (MainContext.current_source().is_destroyed())
            return false;
        if (mixer_evt_idle == 0)
        {
            mixer_evt_idle = Idle.add_full(Priority.DEFAULT,asound_reset_mixer_evt_idle);
            res = mixer.handle_events();
        }
        if ((cond & IOCondition.IN) > 0)
        {
            //the status of mixer is changed. update of display is needed.
            update_display();
        }
        if (((cond & IOCondition.HUP) > 0) || (res < 0))
        {
            //This means there're some problems with alsa.
            warning("""volumealsa: ALSA (or pulseaudio) had a problem:
                    volumealsa: snd_mixer_handle_events() = %d,
                    cond 0x%x (IN: 0x%x, HUP: 0x%x).""", res, cond,
                    IOCondition.IN, IOCondition.HUP);
            var tooltip = ToolTip();
            tooltip.title = _("ALSA (or pulseaudio) had a problem.");
            tooltip.description = _(" Please check the volume-applet logs.");
            tooltip.icon_name = "dialog-error";
            this.tool_tip = tooltip;
            new_tool_tip();
            new_status(StatusNotifier.Status.PASSIVE);
            if (restart_idle == 0)
                restart_idle = Timeout.add_seconds(1, asound_restart);
            return false;
        }*/
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