// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE

  Copyright (C) 
    2012 Stephen Smally
    2012-2013 Mario Guerriero <mario@elementaryos.org>
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as
  published    by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program.  If not, see <http://www.gnu.org/licenses>

  END LICENSE
***/

namespace AppCenter.Utils {	
    
    // Dirs
    public string database_path;
    
    // Icons
    public const string install_icon_filename = Constants.PKGDATADIR + "/icons/browser-download-symbolic.svg";
    public const string remove_icon_filename = Constants.PKGDATADIR + "/icons/user-trash.svg";
    
    public string nicer_pkg_name (string pkg_name) {
        return capitalize_str(pkg_name.replace("-", " "));
    }
    
    public string nicer_pkg_version (string version) {
        var v1 = version.split ("~");
        var v2 = v1[0].split ("+");
        var v3 = v2[0].split ("-");
        var v4 = v3[0].split (":");
        if (v4[1] == null)
            return v3[0];
        else
            return v4[1];
    }
    
    public string capitalize_str (string str) {
        StringBuilder build = new StringBuilder();
        build.append_unichar(str[0].toupper());
        for (int x = 1; x < str.length; x++) {
            build.append_unichar(str[x]);
        }
        return build.str;
    }
    
    public string escape_text (string val) {
		string to_ret;
		to_ret = Markup.escape_text (val);
		to_ret = val.replace ("&", "&amp;");
	    
	    return to_ret;
	}
	
	public string size_to_str (int size) {
		int kB = 1000;
		if (size < kB) {
			return "%d B".printf (size);
		} else if (size < kB * 1000) {
			return "%d kB".printf (size / 1000);
		} else if (size < kB * 1000 * 1000) {
			return "%d MB".printf (size / (1000 * 1000));
		}
		return "%d".printf (size);
	}
	
	/**
	 *  Get a pixbuf from a given icon name at the maximum possible size
	 **/
	public Gdk.Pixbuf? get_pixbuf_from_icon_name (string icon, int max_size = 128) {
	    var theme = Gtk.IconTheme.get_default ();
        try {
            var pixbuf = theme.load_icon (icon, max_size, 0);
		    return pixbuf;   
		} catch (GLib.Error e) {
		    warning (e.message);
            return null;
		} 
	}
	
	/**
	 *  Get a pixbuf from a given path at the maximum possible size
	 **/
	public Gdk.Pixbuf? get_pixbuf_from_path (string path) {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file (path);
		    return pixbuf;   
		} catch (GLib.Error e) {
		    warning (e.message);
            return null;
		}
	}
	
	/**
	 *  Get a themed pixbuf with a given colour
	 **/
	public Gdk.Pixbuf? get_pixbuf_with_colour (string icon_name, Gdk.RGBA rgba = {1, 1, 1, 1}) {
        var icon_name_themed = new ThemedIcon (icon_name);
        Gtk.IconTheme theme = Gtk.IconTheme.get_default ();
	    Gdk.Pixbuf? pix = null;
        Gtk.IconInfo icon_test = null;

	    try {
	        icon_test = theme.lookup_by_gicon (icon_name_themed, 16, 0);
            if (icon_test != null) {
                pix = icon_test.load_symbolic (rgba);
            }
	    } catch (Error e) {
            warning (e.message);
        }
        
        return pix;
	}
	
	// Gtk Actions
	const string ui_string = """
        <ui>
        <popup name="MainActions">
            <menuitem name="Quit" action="Quit"/>
        </popup>
        <popup name="AppMenu">
            <menuitem name="SoftwareProperties" action="SoftwareProperties" />
        </popup>
        </ui>
    """;

    public Gtk.ActionGroup main_actions;
    Gtk.UIManager ui;

}
