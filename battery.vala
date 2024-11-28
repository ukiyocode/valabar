class Battery : Gtk.ToggleButton, Gtk.Buildable {
    private Gtk.Box buttonBox;
    private Gtk.Label buttonLabel;
    private Gtk.Image buttonImage;
    private BatteryInfo info;
    public uint interval { get; set; default = 2000; }

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
            string manufacturer = get_line_from_file(this.dirPath + "manufacturer");
            if (manufacturer == "") {
                this.manufacturer = "Unknown";
            } else {
                this.manufacturer = manufacturer;
            }
            string model_name = get_line_from_file(this.dirPath + "model_name");
            if (model_name == "") {
                this.model_name = "Unknown";
            } else {
                this.model_name = model_name;
            }
            string capacity = get_line_from_file(this.dirPath + "capacity");
            if (capacity == "") {
                this.capacity = "??";
            } else {
                this.capacity = capacity;
            }
            string status = get_line_from_file(this.dirPath + "status");
            if (status == "") {
                this.status = "Unknown";
            } else {
                this.status = status;
            }
        }

        private string get_line_from_file(string filePath) {
            File file = File.new_for_path (filePath);
            if (!file.query_exists()) {
                return "";
            }
            string ret = "";
            try {
                FileInputStream fis = file.read();
                DataInputStream dis = new DataInputStream(fis);
                ret = dis.read_line();
            } catch (Error e) {
                error("Error in battery get_line_from_file: %s\n", e.message);
            }
            return ret;
        }
    }

    public void parser_finished(Gtk.Builder builder) {
        this.info = new BatteryInfo("/sys/class/power_supply/BAT0/");
        this.buttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        this.buttonLabel = new Gtk.Label("");
        this.buttonImage = new Gtk.Image();
        this.buttonBox.add(this.buttonLabel);
        this.buttonBox.add(this.buttonImage);
        this.add(buttonBox);
        updateButton();
        GLib.Timeout.add(interval, batteryCallback);
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