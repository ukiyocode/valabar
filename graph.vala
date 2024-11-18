class Graph : Gtk.Button {
    public string data_file { get; set; }
    public bool data_file_delta { get; set; default = false; }
    public double line_thickness { get; set; default = 1.0; }
    public double max { get; set; default = 100; }
    public double min { get; set; default = 0; }
    public bool dynamic_scale { get; set; default = false; }
    public uint time_range { get; set; default = 160; }
    public uint interval { get; set; default = 2000; }
    public bool flip_x { get; set; default = false; }
    public bool flip_y { get; set; default = false; }

    private uint histLength;
    private List<double?> history;
    private List<double?> delta_history;
    private Gtk.Border cssPadding;

    public void init() {
        this.cssPadding = this.get_style_context().get_padding(Gtk.StateFlags.NORMAL);
        this.width_request = 80 + cssPadding.left + cssPadding.right;
        histLength = this.time_range * 1000 / this.interval;
        history = new List<double?>();
        for (int i = 0; i < histLength; i++) {
            history.append(0);
        }
        if (data_file_delta) {
            delta_history = new List<double?>();
            for (int i = 0; i < histLength; i++) {
                delta_history.append(0);
            }
        }
        if (data_file == "default_network_device") {
            this.data_file = "/sys/class/net/enx2887bada4ab4/statistics/rx_bytes";
        }
        GLib.Timeout.add(interval, timerCallback);
    }

    public bool timerCallback() {
        double val;
        File dataFile = File.new_for_path(this.data_file);
        try {
            FileInputStream fis = dataFile.read();
            DataInputStream dis = new DataInputStream(fis);

            if (data_file_delta) {
                delta_history.append(double.parse(dis.read_line()));
                delta_history.remove(delta_history.nth_data(0));
                val = delta_history.nth_data(histLength - 1) - delta_history.nth_data(histLength - 2);
                //print("%f - %f = %f\n", delta_history.nth_data(histLength - 1), delta_history.nth_data(histLength - 2), val);
            } else {
                val = double.parse(dis.read_line());
            }
            history.append(val);
            history.remove(history.nth_data(0));
        } catch (Error e) {
            stderr.printf("Error while getting graph data: %s\n", e.message);
        }

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

    public override bool draw(Cairo.Context cr) {
        base.draw(cr);
        int width = this.get_allocated_width() - cssPadding.left - cssPadding.right;
        int height = this.get_allocated_height() - cssPadding.top - cssPadding.bottom;
        cr.set_source_rgb(1, 1, 1);
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

        return true;
    }
}