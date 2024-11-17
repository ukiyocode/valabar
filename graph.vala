class Graph : Gtk.Widget {
    public double value { get; set; }
    public double thickness { get; set; default = 1.0; }
    public double max { get; set; default = double.MAX; }
    public double min { get; set; default = double.MIN; }
    public bool dynamicScale { get; set; default = true; }
    public uint time_range { get; set; default = 60; }
    public bool flip_x { get; set; default = false; }
    public bool flip_y { get; set; default = false; }

    public void init() {
        GLib.Timeout.add(500, stuff);
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
            print("%f\n", val);
        } catch (Error e) {
        }
        return true;
    }
}