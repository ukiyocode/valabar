[CCode(cheader_filename="sni-enums.h")]
	public enum Category
	{
		APPLICATION,
		COMMUNICATIONS,
		SYSTEM,
		HARDWARE,
		OTHER
	}
	[CCode(cheader_filename="sni-enums.h")]
	public enum Status
	{
		PASSIVE,
		ACTIVE,
		ATTENTION,
	}
	[CCode(cheader_filename="snproxy.h")]
	public class Proxy: GLib.Object
	{
		[NoAccessorMethod]
		public string bus_name {construct;}
		[NoAccessorMethod]
		public string object_path {construct;}
		[NoAccessorMethod]
		public int icon_size {get; set construct;}
		[NoAccessorMethod]
		public bool use_symbolic {get; set construct;}
		/* Base properties */
		[NoAccessorMethod]
		public Category category {get;}
		[NoAccessorMethod]
		public string id {owned get;}
		[NoAccessorMethod]
		public string title {owned get;}
		[NoAccessorMethod]
		public Status status {get;}
		[NoAccessorMethod]
		public string accessible_desc {owned get;}
		/* Menu properties */
		[NoAccessorMethod]
		public ObjectPath menu {owned get;}
		/* Icon properties */
		[NoAccessorMethod]
		public GLib.Icon icon {owned get;}
		/* Tooltip */
		[NoAccessorMethod]
		public string tooltip_text {owned get;}
		[NoAccessorMethod]
		public GLib.Icon tooltip_icon {owned get;}
		/* Signals */
		public signal void fail();
		public signal void initialized();
		/* Ayatana */
		[NoAccessorMethod]
		public string x_ayatana_label {owned get;}
		[NoAccessorMethod]
		public string x_ayatana_label_guide {owned get;}
		[NoAccessorMethod]
		public uint x_ayatana_ordering_index {get;}

		/*Internal Methods */
		public Proxy(string bus_name, string object_path);
		public void start();
		public void reload();
		/*DBus Methods */
		public void context_menu(int x, int y);
		public void activate(int x, int y);
		public void secondary_activate(int x, int y);
		public void scroll(int dx, int dy);
		public bool ayatana_secondary_activate(uint32 timestamp);
	}