// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE
	 
  Copyright (C) 2013 Mario Guerriero <mario@elementaryos.org>
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

public class AppCenter.Plugins.ElementaryHome : Peas.ExtensionBase,  Peas.Activatable {
    
    private Pages.HomePage home_page;
    
    private string DESKTOP_DIR = Constants.PLUGINSDIR + "/elementary-home/desktop";
    private string ICONS_DIR = Constants.PLUGINSDIR + "/elementary-home/icons";
    
    private File? dir = null;
    
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
        
        // Open desktop dir
        
        this.dir = File.new_for_path (DESKTOP_DIR);
        
        // Get AppsInfo page
        home_page = plugins.get_pages_view ().home_page;
        populate_home_page ();
    }

    public void deactivate () {
        plugins = null;
    }
    
    private void populate_home_page () {
        // Enumerate children
        try {
            var enumerator = dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                string name = file_info.get_name ();
                load_keyfile (name);
            }
        } catch (Error e) {
            warning (e.message);
        }
    }
    
    private void load_keyfile (string file) {
        // Load respective .desktop file and apply to AppsInfo
        string path = DESKTOP_DIR + "/" + file;
        string? exec = null;
        try {
            try {
                var keyfile = new KeyFile ();
                keyfile.load_from_file (path, KeyFileFlags.NONE);
                
                exec = keyfile.get_string ("AppCenterEntry", "Exec");
                
                Pages.HomeButton? button = null;
                
                // Is the icon a custom icon?
                string icon = keyfile.get_string ("AppCenterEntry", "Icon");
                if (".svg" in icon) {
                    try {
                        button = new Pages.HomeButton (keyfile.get_string ("AppCenterEntry", "Name"),
                                                    keyfile.get_string ("AppCenterEntry", "Comment"),
                                                    "applications-other");
                        var pixbuf = new Gdk.Pixbuf.from_file (ICONS_DIR + "/" + icon); 
                        button.set_icon_from_pixbuf (pixbuf);
                    } catch (Error e) {
                        warning (e.message);
                    }
                }
                else {
                    button = new Pages.HomeButton (keyfile.get_string ("AppCenterEntry", "Name"),
                                                    keyfile.get_string ("AppCenterEntry", "Comment"),
                                                    keyfile.get_string ("AppCenterEntry", "Icon"));
                }
                
                button.clicked.connect (() => {
                    if (plugins.get_apps_manager ().load_app_from_id (exec))
                        plugins.get_pages_view ().set_page (PageType.APPSINFO);
                });
                
                home_page.append_button (button);
            } catch (KeyFileError e) {
                warning (e.message);
            }
        } catch (FileError e) {
            warning (e.message);
        }
    }
    
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                     typeof (AppCenter.Plugins.ElementaryHome));
}
