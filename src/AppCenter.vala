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

using Gtk;

using Granite;
using Granite.Services;
using AppCenter;
using AppCenter.Services;

namespace AppCenter {
    
    public Plugins.Manager? plugins_manager = null;
    public SavedState saved_state;
    public Settings settings;
    public UnityProgressBar unity;
        
    public class AppCenter : Granite.Application {

        public MainWindow window = null;
        static string app_cmd_name;
        
        // Context options objects
        static string? package = null;
        static bool refresh_database = false;
        static bool verbose_mode = false;
        // Context option utilities
        public string? opening_package {
            get {
                return package;
            }
        }
        
        construct {

            build_data_dir = Constants.DATADIR;
            build_pkg_data_dir = Constants.PKGDATADIR;
            build_release_name = Constants.RELEASE_NAME;
            build_version = Constants.VERSION;
            build_version_info = Constants.VERSION_INFO;

            program_name = app_cmd_name;
            exec_name = app_cmd_name.down();
            app_years = "2012-2013";
            app_icon = "system-software-installer";
            app_launcher = Constants.LAUNCHER;
            application_id = "net.launchpad.appcenter";
            main_url = "https://launchpad.net/appcenter";
            bug_url = "https://bugs.launchpad.net/appcenter";
            help_url = "https://answers.launchpad.net/appcenter";
            translate_url = "https://translations.launchpad.net/appcenter";
            about_authors = {"Mario Guerriero <mefrio.g@gmail.com>", null };
            about_artists = {"Daniel Forè <daniel.p.fore@gmail.com>", null };
            about_translators = "Launchpad Translators";
            about_license_type = License.GPL_3_0;

        }

        public AppCenter () {

            Logger.initialize (app_cmd_name);
            Logger.DisplayLevel = LogLevel.DEBUG;

            // Settings
            saved_state = new SavedState ();
            settings = new Settings ();
            unity = new UnityProgressBar ();
            
        }

        protected override void activate () {
            
            // Create MainWindow
            if (get_windows () == null) {
                window = new MainWindow (this);
                window.show ();
            }
            else {
                window.present ();
            }
            
            // Plugins
            if (plugins_manager == null)
                plugins_manager = new Plugins.Manager (this);   
            
        }
        
        static const OptionEntry[] entries = {
            { "package", 'p', 0, OptionArg.STRING, ref package, N_("Load a package from the given id"), "" },
            { "refresh-database", 'r', 0, OptionArg.NONE, ref refresh_database, N_("Recreates database files"), null },
            { "verbose-mode", 'v', 0, OptionArg.NONE, ref verbose_mode, N_("Use debug verbose mode"), null },
            { null }
        };
        
        public static int main (string[] args) {
            
            app_cmd_name = "AppCenter";
            
            // Context options
            var context = new OptionContext ("File");
            context.add_main_entries (entries, Constants.GETTEXT_PACKAGE);
            
            try {
                context.parse (ref args);
            }
            catch(Error e) {
                warning (e.message);
            }
            
            // Init libs
            AppStore.init ();
            AppStore.set_verbose_mode (verbose_mode);  
            
            // Create AppCenter
            var app = new AppCenter ();  
            
            // Database location
            Utils.database_path = GLib.Environment.get_user_data_dir () + "/appcenter/database.db";
            
            // AppsManager
            apps_manager = new AppStore.AppsManager (Utils.database_path);
            
            // Handle context options
            if (refresh_database) {
                apps_manager.build_database ();
                return 0;
            }
           var control = new PackageKit.Control ();
           if (control.locked)
            debug ("");
            // Run AppCenter
            return app.run (args);

        }

    }
}
