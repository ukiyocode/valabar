class CPUUsageMeter : Gtk.Button
{
    //private File _cPUFile;

    public CPUUsageMeter() {
        //_cPUFile = File.new_for_path ("/proc/stat");
    }

    public bool perCoreCPUUsageCallback() {
        File cPUFile = File.new_for_path ("/proc/stat");
        try {
            FileInputStream fis = cPUFile.read();
            DataInputStream dis = new DataInputStream(fis);
            string line;
    
            while ((line = dis.read_line ()) != null) {
                print ("%s\n", line);
            }
        } catch (Error e) {
            print ("Error: %s\n", e.message);
        }
        //  gchar     tempString[20];
        //  gint      counter;
        //  gint      i;
        //  gfloat    load;
        //  FILE* fp;
        //  gchar *scrap;

        //  scrap=(gchar *)g_malloc(15);
        
        //  fp = fopen ("/proc/stat", "r");

        //  for (counter = 0; counter <= processors; counter++) {
        //      up1[counter]=0;
        //      fscanf (fp, "%s %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld",scrap,&a[0],&a[1],&a[2],&a[3],&a[4],&a[5],&a[6],&a[7],&a[8],&a[9]);
        //      if (strncmp(scrap,"cpu",3) != 0) break;
        //      for (i =0; i < 8; i++) up1[counter]+= a[i];
        //      idle1[counter] = a[3]+a[4];
        //      if (counter == 0) {
        //          // calculates total up time
        //          sprintf(tempString,"%3.5f",(float)(up1[0]/(24.0*3600.0*100.0 ) / (float)processors));  // format decimal days
        //      }
        //      up[counter]=up1[counter]-up[counter];
        //      idle[counter]=idle1[counter]-idle[counter];
        //      load=((float)(up[counter]-idle[counter])/(float)up[counter])*100.0;
        //      // now you halve the load..

        //      // update staic variables for next loop
        //      up[counter]=up1[counter];
        //      idle[counter]=idle1[counter];
        //  }
        //  fclose(fp);

        return true;
    }
}