public class Logger {

    private static FileStream log_file;

    public static void init_logging() {
        // Open file for writing
        log_file = FileStream.open(ValaBar.exePath + "/valabar.log", "a");
        
        // Set up log handler
        Log.set_handler(null, LogLevelFlags.LEVEL_MASK, (domain, level, message) => {
            if (log_file != null) {
                // Get current time
                var now = new DateTime.now_local();
                string timestamp = now.format("%Y-%m-%d %H:%M:%S");
                
                // Write log message to file
                log_file.printf("[%s] %s: %s\n", timestamp, level.to_string(), message);
                log_file.flush();
            }
        });
    }
}