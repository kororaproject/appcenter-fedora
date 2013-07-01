// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE
	
  Copyright (C) 2013 Mario Guerriero <mefrio.g@gmail.com>
  This program is free software: you can redistribute it and/or modify it	
  under the terms of the GNU Lesser General Public License version 3, as published	
  by the Free Software Foundation.
	
  This program is distributed in the hope that it will be useful, but	
  WITHOUT ANY WARRANTY; without even the implied warranties of	
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR	
  PURPOSE.  See the GNU General Public License for more details.
	
  You should have received a copy of the GNU General Public License along	
  with this program.  If not, see <http://www.gnu.org/licenses/>	
  
  END LICENSE	
***/

public class AppCenter.Plugins.RatingsReviews : Peas.ExtensionBase,  Peas.Activatable {
    
    private Pages.AppsInfo apps_info;
    private Json.Parser parser;
    
    public Services.Plugins.Interface? plugins = null;
    public Object object { owned get; construct; }
   
    public void update_state () {
        return;
    }

    public void activate () {
        // Get plugin interface
        Value value = Value (typeof (GLib.Object));
        get_property ("object", ref value);
        plugins = (Services.Plugins.Interface) value.get_object();
        
        load_parser.begin ();
        
        // Get AppsInfo page
        apps_info = plugins.get_pages_view ().apps_info;
        apps_info.load_info_finished.connect (on_load_info_finished);
    }

    public void deactivate () {
        plugins = null;
    }
    
    private async void load_parser () {
        // Open ratings and reviews files
        var file = File.new_for_uri ("https://reviews.ubuntu.com/reviews/api/1.0/review-stats/ubuntu/any/");
        
        file.read_async.begin (Priority.DEFAULT, null, (obj, res) => {
		    try {
			    FileInputStream @is = file.read_async.end (res);
			    DataInputStream dis = new DataInputStream (@is);
                
                create_parser.begin (dis);
		    } catch (Error e) {
			    warning (e.message);
		    }
		    
		    
	    });

    }

    private async void create_parser (DataInputStream dis) {
        string line;
        var text = new StringBuilder ();
        
        try {
            text.append ("{ \"ratings\": ");
            while ((line = yield dis.read_line_async ()) != null) {
                text.append (line);
                text.append_c ('\n');
            }
            text.append_c ('}');
        } catch (IOError e) {
            warning (e.message);
        }
        
        // JSon parser
        parser = new Json.Parser ();
        try {
            parser.load_from_data (text.str);
        } catch (Error e) {
            warning (e.message);
        }
    }

    private void on_load_info_finished () {
        if (plugins == null)
                return;

        // Check package name and set additional infos provided by this plugin
        set_ratings_and_reviews_for_pkg_name (apps_info.app.package.get_name ());
    }
    
    private void set_ratings_and_reviews_for_pkg_name (string pkg_name) {
        var root_object = parser.get_root ().get_object ();
        
        foreach (var rating_node in root_object.get_array_member ("ratings").get_elements ()) {
            var rating = rating_node.get_object ();
            string name = rating.get_string_member ("package_name");
            var pkg_rating = rating.get_string_member ("ratings_average");
            if (name == pkg_name)
                debug ("%s: %d\n", name, int.parse (pkg_rating));
        }
    }
    
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (AppCenter.Plugins.RatingsReviews));
}
