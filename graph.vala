class Graph : Gtk.Button {
    public double value { get; set; }
    public double thickness { get; set; default = 1.0; }
    public double max { get; set; default = double.MAX; }
    public double min { get; set; default = double.MIN; }
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
        min = 0;//(double)int32.MIN;
        max = 100000;//(double)int32.MAX;
        double span = max - min;
        double val;
        File dataFile = File.new_for_path ("/sys/class/thermal/thermal_zone6/temp");
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

    public override bool draw (Cairo.Context cr) {
        int width = this.get_allocated_width();
        int height = this.get_allocated_height();
        cr.set_source_rgb(1, 1, 1);
        cr.set_line_width(1);
        double step = (double)width / (double)(histLength - 1);
        double x = width;
        cr.move_to(width, height - history.nth_data(0) * height);
        foreach (double y in history) {
            cr.line_to(x, height - y * height);
            x -= step;
        }
        cr.stroke();

        return true;
    }
}