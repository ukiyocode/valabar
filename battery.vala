[DBus (name = "org.freedesktop.login1.Session")]
public interface Login1Iface: Object
{
    public abstract void SetBrightness(string subsystem,string name,uint brightness) throws Error;
}

class BatteryInfo {
    public string manufacturer { get; private set; }
    public string model_name { get; private set; }
    public string capacity { get; private set; }
    public string status { get; private set; }
    public string percentage {
        owned get {
            return (uint.parse(capacity) / 10 * 10).to_string();
        }
    }
    private string dirPath;

    public BatteryInfo(string dirPath) {
        this.dirPath = dirPath;
        updateData();
    }

    public void updateData() {
        string manufacturer = ValaBar.get_line_from_file(this.dirPath + "manufacturer");
        if (manufacturer == "") {
            this.manufacturer = "Unknown";
        } else {
            this.manufacturer = manufacturer;
        }
        string model_name = ValaBar.get_line_from_file(this.dirPath + "model_name");
        if (model_name == "") {
            this.model_name = "Unknown";
        } else {
            this.model_name = model_name;
        }
        string capacity = ValaBar.get_line_from_file(this.dirPath + "capacity");
        if (capacity == "") {
            this.capacity = "??";
        } else {
            this.capacity = capacity;
        }
        string status = ValaBar.get_line_from_file(this.dirPath + "status");
        if (status == "") {
            this.status = "Unknown";
        } else {
            this.status = status;
        }
    }
}

class Battery : Gtk.ToggleButton, Gtk.Buildable {
    private Gtk.Box buttonBox;
    private Gtk.Label buttonLabel;
    private Gtk.Image buttonImage;
    private BatteryInfo info;
    public uint interval { get; set; default = 2000; }
    private uint backlightMax;
    private uint backlightStep;
    private Login1Iface login1;
    private Popup batteriesPopup;

    public void parser_finished(Gtk.Builder builder) {
        this.events |= Gdk.EventMask.SCROLL_MASK;
        this.info = new BatteryInfo("/sys/class/power_supply/BAT0/");
        this.buttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        this.buttonLabel = new Gtk.Label("");
        this.buttonImage = new Gtk.Image();
        this.buttonBox.add(this.buttonLabel);
        this.buttonBox.add(this.buttonImage);
        this.add(buttonBox);
        updateButton();
        GLib.Timeout.add(interval, batteryCallback);
        backlightMax = uint.parse(ValaBar.get_line_from_file("/sys/class/backlight/intel_backlight/max_brightness"));
        if (backlightMax <= 0) {
            error("In battery.vala. backlightMax should be a positive value.");
        }
        backlightStep = backlightMax / 100;
        if (backlightStep <= 0) {
            backlightStep = 1;
        }
        this.toggled.connect(on_toggled);
        this.scroll_event.connect(on_scroll);
    }

    private void on_toggled() {
        if (this.get_active()) {
            this.batteriesPopup = new Popup(this);
            this.batteriesPopup.show_all();
        } else {
            this.batteriesPopup.destroy();
            this.batteriesPopup = null;
        }
    }

    public bool on_scroll(Gdk.EventScroll event) {
        uint newBacklight = getBacklight();
        if (event.direction == Gdk.ScrollDirection.DOWN) {
            newBacklight -= backlightStep;
        }
        else if (event.direction == Gdk.ScrollDirection.UP) {
            newBacklight += backlightStep;
        }
        setBacklight(newBacklight);
        return true;
    }

    private void setBacklight(uint backlight) {
        try {
            login1 = Bus.get_proxy_sync(BusType.SYSTEM, "org.freedesktop.login1", "/org/freedesktop/login1/session/self");
            login1.SetBrightness("backlight", "intel_backlight", backlight.clamp(backlightStep, backlightMax));
        } catch (Error e) {
            error("In battery.vala. Error while setting backlight");
        }
    }

    private uint getBacklight() {
        string backlight = ValaBar.get_line_from_file("/sys/class/backlight/intel_backlight/brightness");
        return uint.parse(backlight);
    }

    public bool batteryCallback() {
        this.info.updateData();
        this.updateButton();
        return true;
    }

    private void updateButton() {
        string imgPath = ValaBar.exePath;

        if (this.info.status == "Discharging") {
            imgPath += "/images/battery-level-" + this.info.percentage + "-discharging-symbolic.svg";
        } else if ((this.info.status == "Charging") || (this.info.status == "Not charging") || (this.info.status == "Full")) {
            imgPath += "/images/battery-level-" + this.info.percentage + "-charging-symbolic.svg";
        }
        this.buttonLabel.label = info.capacity + "%";
        
        if (imgPath != this.buttonImage.file) {
            this.buttonBox.remove(this.buttonImage);
            this.buttonImage = new Gtk.Image.from_file(imgPath);
            this.buttonBox.add(this.buttonImage);
            this.show_all();
        }
    }
}