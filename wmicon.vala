public class WMIcon : Object
{
    private class IconInfo {
        public int width;
        public int height;
        public ulong data_offset_cardinals;
        public ulong pixel_count;

        public IconInfo(int width, int height, ulong data_offset_cardinals, ulong pixel_count) {
            this.width = width;
            this.height = height;
            this.data_offset_cardinals = data_offset_cardinals;
            this.pixel_count = pixel_count;
        }
    }

    public Gtk.Image iconImage { get; construct set; }
    private string iconName;

    public WMIcon(ulong xid) {
        print("Xid: %lu\n", xid);
        iconName = "image-missing-symbolic";
        iconImage = new Gtk.Image.from_icon_name(iconName);

        Gdk.X11.Display display = (Gdk.X11.Display)Gdk.Display.get_default();
        unowned X.Display xdisplay = display.get_xdisplay();
        X.Atom iconAtom = xdisplay.intern_atom("_NET_WM_ICON", true);
        if (iconAtom == X.None) { // Define Xlib.NONE if available, otherwise 0 is common
            warning("Could not find _NET_WM_ICON atom.");
            return;
        }

        X.Atom actualType;
        int actualFormat;
        ulong nItems;
        ulong bytesAfter;
        uint8* propData = null;
        int status = xdisplay.get_window_property(xid, iconAtom, 0, long.MAX, false, X.ANY_PROPERTY_TYPE, 
            out actualType,out actualFormat, out nItems, out bytesAfter, out propData);

        if (status != X.ErrorCode.SUCCESS || propData == null || nItems == 0) {
            warning("Failed to get _NET_WM_ICON property. Status: %d. Window might not exist or has no icon.", status);
            if (propData != null) {
                X.free (propData);
            }
            return;
        }
        if (actualFormat != 32) {
            warning("Warning: Unexpected icon data format (%d-bit, expected 32-bit). Parsing might fail.", actualFormat);
            return;
        }

        print("data size: %lu\n", nItems);

        int best_icon_index = -1;
        ulong best_icon_size = 0;
        ulong current_offset = 0; // Offset in number of CARDINALs (ulong)
        ulong data_size_cardinals = nItems;
        ulong* data_ptr = (ulong*)propData; // Cast raw data to array of ulong

        // Array to hold info about found icons
        var icons = new Gee.ArrayList<IconInfo>();

        while (current_offset < data_size_cardinals) {
            if (current_offset + 1 >= data_size_cardinals) {
                warning ("Icon data ended prematurely (missing height or data). Offset: %lu, Total: %lu", current_offset, data_size_cardinals);
                break; // Not enough data for width/height
            }

            ulong width = data_ptr[current_offset];
            ulong height = data_ptr[current_offset + 1];
            ulong icon_pixel_count = width * height;

            if (width == 0 || height == 0) {
                    warning("Found icon with zero dimension (w=%lu, h=%lu) at offset %lu. Skipping.", width, height, current_offset);
                    // Technically valid but useless. How to advance? Assume it takes width+height fields only?
                    // Let's assume it's corrupt and stop parsing here. A safer approach might be needed.
                    break;
            }

            // Check if there's enough data left for the pixels
            if (current_offset + 2 + icon_pixel_count > data_size_cardinals) {
                warning ("Icon data ended prematurely (missing pixel data). Offset: %lu, Required: %lu, Total: %lu",
                            current_offset, current_offset + 2 + icon_pixel_count, data_size_cardinals);
                break; // Not enough data for the pixels
            }

            //stdout.printf ("Found icon: %lu x %lu pixels.\n", width, height);

            // Store info about this icon
            icons.add(new IconInfo ((int)width, (int)height, current_offset + 2, icon_pixel_count));

            // Check if this is the largest so far
            if (width * height > best_icon_size) {
                best_icon_size = width * height;
                best_icon_index = icons.size - 1; // Index in our 'icons' list
            }

            // Advance offset to the next icon's width field
            current_offset += 2 + icon_pixel_count;
        }
        print("best icon index: %i\n", best_icon_index);
        

        // --- 7. Create Pixbuf from Selected Icon ---
        if (best_icon_index != -1) {
            var selected_icon = icons[best_icon_index];
            stdout.printf("Selected largest icon: %d x %d\n", selected_icon.width, selected_icon.height);

            // Calculate byte offset and size of the pixel data
            // Assuming sizeof(ulong) here matches the CARDINAL size from Xlib
            ulong byte_offset = selected_icon.data_offset_cardinals * sizeof(ulong);
            ulong byte_size = selected_icon.pixel_count * sizeof(ulong); // Total bytes for pixel data

            ulong size32 = selected_icon.pixel_count * 2;

            uint8* source_ptr = propData + byte_offset;
            uint32[] data32 = ((uint32[])source_ptr)[0:size32];
            uint32[] fixedData = new uint32[selected_icon.pixel_count];

            for (int i=0; i<fixedData.length; i++) {
                fixedData[i] = data32[i*2];
            }
            uint8[] pixel_data = (uint8[])fixedData;

            size_t stride = selected_icon.width * sizeof(uint32);

            //B8G8R8A8_PREMULTIPLIED
            Gdk.MemoryTexture mt = new Gdk.MemoryTexture(selected_icon.width, selected_icon.height, 
                Gdk.MemoryFormat.B8G8R8A8, new Bytes(pixel_data) , stride);

            iconImage.set_from_paintable(mt);
        }
        X.free(propData);
    }
}