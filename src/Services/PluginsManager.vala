// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE

  Copyright (C) 2012-2013 Mario Guerriero <mario@elementaryos.org>
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

namespace AppCenter.Services.Plugins {
    
    public class Interface : Object {
        AppCenter app;
        Manager manager;

        public Interface (Manager manager, AppCenter app) {
            this.app = app;
            this.manager = manager;
        }
        
        public AppCenter? get_app () {
            return app;
        }
        
        public AppStore.AppsManager? get_apps_manager () {
            return apps_manager;
        }
        
        public MainWindow? get_main_window () {
            return app.window;
        }
        
        public Widgets.PagesView? get_pages_view () {
            return app.window.pages_view;
        }
        
    }


    public class Manager : Object {

        public signal void hook_widget (Gtk.Widget widget);

        Peas.Engine engine;
        Peas.ExtensionSet exts;

        GLib.Settings schema;
        string schema_field;
        
        public Interface plugin_iface { private set; public get; }
        
        public Manager (AppCenter app) {
            schema = settings.schema;
            schema_field = "plugins-enabled";

            plugin_iface = new Interface (this, app);

            /* Let's init the engine */
            engine = Peas.Engine.get_default ();
            engine.enable_loader ("python");
            engine.enable_loader ("gjs");
            engine.add_search_path (Constants.PLUGINSDIR, null);
            schema.bind (schema_field, engine, "loaded-plugins", SettingsBindFlags.DEFAULT);
            
            exts = new Peas.ExtensionSet (engine, typeof(Peas.Activatable), "object", plugin_iface, null);
            
            exts.extension_added.connect( (info, ext) => {  
                ((Peas.Activatable)ext).activate();
            });
            exts.extension_removed.connect((info, ext) => {
                ((Peas.Activatable)ext).deactivate();
            });
            
            exts.foreach (on_extension_foreach);
            
        }
        
        void on_extension_foreach (Peas.ExtensionSet set, Peas.PluginInfo info, Peas.Extension extension) {
            var core_list = engine.get_plugin_list ().copy ();
            for (int i = 0; i < core_list.length(); i++) {
                string module = core_list.nth_data (i).get_module_name ();
                if (module == info.get_module_name ())
                    ((Peas.Activatable)extension).activate();
            }
        }

    }
}
