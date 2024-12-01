class Graph : Gtk.Button, Gtk.Buildable {
    public string data_file { get; set; }
    public bool data_file_delta { get; set; default = false; }
    public uint data_token_number { get; set; default = 0; }
    public double line_thickness { get; set; default = 1.0; }
    public double max { get; set; default = 100; }
    public double min { get; set; default = 0; }
    public bool dynamic_scale { get; set; default = false; }
    public uint time_range { get; set; default = 160; }
    public uint interval { get; set; default = 2000; }
    public bool flip_x { get; set; default = false; }
    public bool flip_y { get; set; default = false; }
    public string unit_symbol { get; set; default = ""; }
    public double unit_multiplier { get; set; default = 1.0; }

    private uint histLength;
    private List<double?> history;
    private List<double?> delta_history;
    private Gtk.Border cssPadding;
    //private bool defNetDevice = false;

    public void parser_finished(Gtk.Builder builder) {
        this.cssPadding = this.get_style_context().get_padding(Gtk.StateFlags.NORMAL);
        this.width_request = 80 + cssPadding.left + cssPadding.right;
        histLength = this.time_range * 1000 / this.interval;
        history = new List<double?>();
        double initVal;
        for (int i = 0; i < histLength; i++) {
            history.append(0);
        }
        initVal = getData();
        if (data_file_delta) {
            delta_history = new List<double?>();
            for (int i = 0; i < histLength; i++) {
                delta_history.append(initVal);
            }
        }

        GLib.Timeout.add(interval, timerCallback);
    }

    private string getDefaultNetDev () {
        string output;
        try {
            Process.spawn_command_line_sync("ip route show default", out output);
        } catch (SpawnError e) {
            debug("Failed getting default network device: %s\n", e.message);
        }
        if (output == null) {
            return "default_network_device";
        }
        MatchInfo regexMatch;
        if (/default via [0-9.]+ dev ([^ ]+)/.match(output, 0, out regexMatch)) {
            if (regexMatch.get_match_count() == 2) {
                return regexMatch.fetch(1);
            }
        }
        return "default_network_device";
    }

    private double getData() {
        if (this.data_file.contains("default_network_device")) {
            this.data_file = "/sys/class/net/" + getDefaultNetDev() + "/statistics/rx_bytes";
        }
        File dataFile = File.new_for_path(this.data_file);
        if (!dataFile.query_exists()) {
            return 0;
        }
        double ret = 0;
        try {
            FileInputStream fis = dataFile.read();
            DataInputStream dis = new DataInputStream(fis);

            ret = double.parse(dis.read_line().tokenize_and_fold("", null)[this.data_token_number]);
        } catch (Error e) {
            error("Error while getting graph data: %s\n", e.message);
        }
        return ret;
    }

    public bool timerCallback() {
        double val;
        
        if (data_file_delta) {
            delta_history.append(getData());
            delta_history.remove(delta_history.nth_data(0));
            val = delta_history.nth_data(histLength - 1) - delta_history.nth_data(histLength - 2);
        } else {
            val = getData();
        }
        history.append(val);
        history.remove(history.nth_data(0));

        this.queue_draw();
        return true;
    }

    private double calcStep(double width) {
        double ret = width / (double)(this.histLength - 1);
        if (this.flip_x) {
            return -ret;
        }
        return ret;
    }

    private double calcX(double x, double width) {
        if (this.flip_x) {
            return width - x + cssPadding.left;
        }
        return x + cssPadding.left;
    }

    private double calcY(double y, double height) {
        y = (y - this.min) / (this.max - this.min);
        if (this.flip_y) {
            return y * height + cssPadding.top;
        }
        return height - y * height + cssPadding.bottom;
    }

    private string toSI(double d, string format)
    {
        if (d == 0) {
            return d.format(new char[20], format);
        }
        char[] incPrefixes = { 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
        char[] decPrefixes = { 'm', 'u', 'n', 'p', 'f', 'a', 'z', 'y' };

        int degree = (int)Math.floor(GLib.Math.log10(d.abs()) / 3);
        degree = degree.clamp(-8, 8);
        double scaled = d * Math.pow(1000, -degree);

        char? prefix = null;
        if (degree < 0) {
            prefix = decPrefixes[-degree - 1];
        } else if (degree > 0) {
            prefix = incPrefixes[degree - 1];
        }

        if (prefix == null) {
            return scaled.format(new char[20], format);
        }
        return scaled.format(new char[20], format) + prefix.to_string();
    }


    public override bool draw(Cairo.Context cr) {
        base.draw(cr);
        int width = this.get_allocated_width() - cssPadding.left - cssPadding.right;
        int height = this.get_allocated_height() - cssPadding.top - cssPadding.bottom;
        cr.set_source_rgb(0.8, 0.8, 0.8);
        cr.set_line_width(this.line_thickness);
        double step = calcStep(width);
        double x = calcX(0, width);
        if (dynamic_scale) {
            this.min = double.MAX;
            this.max = double.MIN;
            foreach (double y in history) {
                if (y > this.max) { this.max = y; }
                if (y < this.min) { this.min = y; }
            }
        }
        cr.move_to(x, calcY(history.nth_data(0), height));
        foreach (double y in history) {
            cr.line_to(x, calcY(y, height));
            x += step;
        }
        cr.stroke();
        cr.select_font_face("monospace", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size(12);
        cr.set_source_rgb(1, 1, 1);
        cr.move_to(cssPadding.left, cssPadding.top + 10);
        double text_value;
        if (this.dynamic_scale) {
            text_value = this.max;
        } else {
            text_value = history.nth_data(histLength - 1);
        }
        cr.show_text(toSI(text_value * this.unit_multiplier, "%.1f") + this.unit_symbol);

        return true;
    }
}