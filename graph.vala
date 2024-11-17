class Graph : Gtk.Button {
    public double value { get; set; }
    public double thickness { get; set; default = 1.0; }
    public double max { get; set; default = double.MAX; }
    public double min { get; set; default = double.MIN; }
    public bool dynamicScale { get; set; default = true; }
    public uint time_range { get; set; default = 60; }
    public uint interval { get; set; default = 1000; }
    public bool flip_x { get; set; default = false; }
    public bool flip_y { get; set; default = false; }

    private uint histLength = 5;//this.time_range * 1000 / this.interval
    private List<double?> history;

    public void init() {
        this.width_request = 80;
        history = new List<double?>();
        for (int i = 0; i < histLength; i++) {
            history.append(0);
        }
        GLib.Timeout.add(interval, stuff);
    }

    public bool stuff() {
        min = (double)int32.MIN;
        max = (double)int32.MAX;
        double span = max - min;
        double val;
        File dataFile = File.new_for_path ("/dev/random");
        try {
            FileInputStream fis = dataFile.read();
            DataInputStream dis = new DataInputStream(fis);

            val = (double)dis.read_int32();
            val = (val + min.abs()) / span;
            history.prepend(val);
            history.remove(history.nth_data(histLength));
            foreach (double d in history) {
                print("%.2f, ", d);
            }
            print("\n");
            //print("%f\n", val);
        } catch (Error e) {
        }
        return true;
    }
}