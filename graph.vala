class Graph : Gtk.Button {
    public string data_file { get; set; }
    public bool data_file_delta { get; set; default = false; }
    public double line_thickness { get; set; default = 1.0; }
    public double max { get; set; default = 100; }
    public double min { get; set; default = 0; }
    public bool dynamicScale { get; set; default = true; }
    public uint time_range { get; set; default = 160; }
    public uint interval { get; set; default = 2000; }
    public bool flip_x { get; set; default = false; }
    public bool flip_y { get; set; default = false; }

    private uint histLength;
    private List<double?> history;

    public void init() {
        this.width_request = 80;
        histLength = this.time_range * 1000 / this.interval;
        history = new List<double?>();
        for (int i = 0; i < histLength; i++) {
            history.append(0);
        }
        GLib.Timeout.add(interval, timerCallback);
    }

    public bool timerCallback() {
        double span = max - min;
        double val;
        File dataFile = File.new_for_path (this.data_file);
        try {
            FileInputStream fis = dataFile.read();
            DataInputStream dis = new DataInputStream(fis);

            val = double.parse(dis.read_line());
            val = (val + min.abs()) / span;
            history.prepend(val);
            history.remove(history.nth_data(histLength));
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
            return width - x;
        }
        return x;
    }

    private double calcY(double y, double height) {
        if (this.flip_y) {
            return y * height;
        }
        return height - y * height;
    }

    public override bool draw(Cairo.Context cr) {
        base.draw(cr);
        int width = this.get_allocated_width();
        int height = this.get_allocated_height();
        cr.set_source_rgb(1, 1, 1);
        cr.set_line_width(this.line_thickness);
        double step = calcStep(width);
        double x = calcX(0, width);
        cr.move_to(x, calcY(history.nth_data(0), height));
        foreach (double y in history) {
            cr.line_to(x, calcY(y, height));
            x += step;
        }
        cr.stroke();

        return true;
    }
}