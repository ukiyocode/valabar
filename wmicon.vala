public class WMIcon : Object
{
    public Gtk.Image iconImage { get; construct set; }
    private string iconName;

    public WMIcon(ulong xid, int size) {
        iconName = "image-missing-symbolic";
        iconImage = new Gtk.Image.from_icon_name(iconName);
        iconImage.set_pixel_size(size);

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

        ulong current_offset = 0; // Offset in number of CARDINALs (ulong)
        ulong* data_ptr = (ulong*)propData; // Cast raw data to array of ulong

        int bestWidth = 0;
        int bestHeight = 0;
        ulong bestOffset = -1;
        int sizeDiff = int.MAX;
        while (current_offset < nItems) {
            if (current_offset + 1 >= nItems) {
                warning ("Icon data ended prematurely (missing height or data). Offset: %lu, Total: %lu", current_offset, nItems);
                break; // Not enough data for width/height
            }

            ulong width = data_ptr[current_offset];
            ulong height = data_ptr[current_offset + 1];
            if (width == 0 || height == 0) {
                warning("Found icon with zero dimension (w=%lu, h=%lu) at offset %lu. Skipping.", width, height, current_offset);
                break;
            }

            ulong icon_pixel_count = width * height;
            

            int h = (int)height;
            if ((size - h).abs() < sizeDiff) {
                sizeDiff = (size - h).abs();
                bestWidth = (int)width;
                bestHeight = h;
                bestOffset = current_offset + 2;
            }

            // Check if there's enough data left for the pixels
            if (current_offset + 2 + icon_pixel_count > nItems) {
                warning ("Icon data ended prematurely (missing pixel data). Offset: %lu, Required: %lu, Total: %lu",
                            current_offset, current_offset + 2 + icon_pixel_count, nItems);
                break; // Not enough data for the pixels
            }

            // Advance offset to the next icon's width field
            current_offset += 2 + icon_pixel_count;
        }
        

        // --- 7. Create Pixbuf from Selected Icon ---
        if (bestOffset != -1) {
            //IconInfo selected_icon = icons[best_icon_index];
            ulong pixel_count = bestWidth * bestHeight;

            uint32[] fixedData = new uint32[pixel_count];

            for (ulong i = 0; i < pixel_count; i++) {
                fixedData[i] = (uint32)data_ptr[bestOffset + i];
            }
            uint8[] pixel_data = (uint8[])fixedData;

            size_t stride = bestWidth * sizeof(uint32);

            Gdk.MemoryTexture mt = new Gdk.MemoryTexture(bestWidth, bestHeight, 
                Gdk.MemoryFormat.B8G8R8A8, new Bytes(pixel_data) , stride);

            iconImage.set_from_paintable(mt);
            iconImage.set_pixel_size(size);
        }
        X.free(propData);
    }
}