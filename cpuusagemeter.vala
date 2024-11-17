class CPUUsageMeter : Gtk.Button
{
    //private File _cPUFile;
    private IdleTotal[] values;
    private IdleTotal[] oldValues;
    private double[] usages;
    private List<string> lines;
    private uint numOfCPUCores;
    private Gtk.ProgressBar[] coreBars;
    private Gtk.Box contentsBox;

    class IdleTotal {
        public uint64 idle { get; }
        public uint64 total { get; }

        public IdleTotal(uint64 idle, uint64 total) {
            this._idle = idle;
            this._total = total;
        }
    }

    public void init() {
        this.lines = getLines();
        this.numOfCPUCores = this.lines.length();
        this.values = new IdleTotal[this.numOfCPUCores];
        this.coreBars = new Gtk.ProgressBar[this.numOfCPUCores];
        this.contentsBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        for (int i = 0; i < this.numOfCPUCores; i++) {
            this.values[i] = parseStatLine(lines.nth_data(i));
            this.coreBars[i] = new Gtk.ProgressBar();
            this.coreBars[i].orientation = Gtk.Orientation.VERTICAL;
            this.coreBars[i].inverted = true;
            this.contentsBox.add(coreBars[i]);
        }
        this.add(contentsBox);
        GLib.Timeout.add(2000, perCoreCPUUsageCallback);
    }

    private IdleTotal parseStatLine(string line) {
        string[] cpuTimes = line.split(" ");
        uint64 idle = uint64.parse(cpuTimes[4]);
        uint64 total = 0;
        for (int i = 1; i < cpuTimes.length; i++) {
            total += uint64.parse(cpuTimes[i]);
        }
        return new IdleTotal(idle, total);
    }

    private List<string> getLines() {
        File cpuFile = File.new_for_path ("/proc/stat");
        List<string> rets = new List<string>();
        try {
            FileInputStream fis = cpuFile.read();
            DataInputStream dis = new DataInputStream(fis);
            string line = dis.read_line(); //skip 1st line
            
            while ((line = dis.read_line()) != null) {
                if (!line.has_prefix("cpu")) { //break after all cpu cores
                    break;
                }
                rets.append(line);
            }
        } catch (Error e) {
            print ("Error in CPU Usage Callback: %s\n", e.message);
        }
        return rets;
    }

    public bool perCoreCPUUsageCallback() {
        this.lines = getLines();
        this.oldValues = this.values;
        this.values = new IdleTotal[this.numOfCPUCores];
        this.usages = new double[this.numOfCPUCores];
        double totalDelta;
        double idleDelta;

        for (int i = 0; i < this.numOfCPUCores; i++) {
            this.values[i] = parseStatLine(lines.nth_data(i));
            totalDelta = (double)(this.values[i].total - this.oldValues[i].total);
            idleDelta = (double)(this.values[i].idle - this.oldValues[i].idle);
            this.usages[i] = ((totalDelta - idleDelta) / totalDelta);
            this.coreBars[i].set_fraction(this.usages[i]);
        }
        //this.show_all();
        //print("%f\n", this.usages[0]);
        return true;
    }
}