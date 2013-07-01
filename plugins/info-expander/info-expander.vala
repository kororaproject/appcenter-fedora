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

public class AppCenter.Plugins.InfoExpander : Peas.ExtensionBase,  Peas.Activatable {
    
    private Pages.AppsInfo apps_info;
    
    private File? dir = null;
    private const string DESKTOP_DIR = Constants.PLUGINSDIR + "/info-expander/desktop";
    private string ICONS_DIR = Constants.PLUGINSDIR + "/info-expander/icons";
    
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
        apps_info = plugins.get_pages_view ().apps_info;
        apps_info.load_info_finished.connect (on_load_info_finished);
    }

    public void deactivate () {
        plugins = null;
    }
    
    private void on_load_info_finished () {
        if (plugins == null)
                return;
        
        if (dir == null)
            return;
            
        // Check package name and set additional infos provided by this plugin
        set_info_for_pkg_name (apps_info.app.package.get_name ());
    }
    
    private void set_info_for_pkg_name (string pkg_name) {
        // Enumerate children and check for a good one
        try {
            var enumerator = dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                string name = file_info.get_name ();
                if (name == (pkg_name + ".desktop"))
                    load_keyfile (pkg_name + ".desktop");
            }
        } catch (Error e) {
            warning (e.message);
        }
    }
    
    private void load_keyfile (string file) {
        // Load respective .desktop file and apply to AppsInfo
        string path = DESKTOP_DIR + "/" + file;
        try {
            try {
                var keyfile = new KeyFile ();
                keyfile.load_from_file (path, KeyFileFlags.NONE);
                
                apps_info.set_name    (keyfile.get_string ("AppCenterEntry", "Name"));
                apps_info.set_summary (keyfile.get_string ("AppCenterEntry", "Comment"));
                // Check custom icons
                string icon = keyfile.get_string ("AppCenterEntry", "Icon");
                if (".svg" in icon)
                    apps_info.set_icon_from_path (ICONS_DIR + "/" + icon);
                else
                    apps_info.set_icon (icon);
                    
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
                                     typeof (AppCenter.Plugins.InfoExpander));
}
