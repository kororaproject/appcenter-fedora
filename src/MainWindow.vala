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

using Gtk;
using AppCenter.Utils;
using AppCenter.Widgets;

namespace AppCenter {
    // Elements which should be accessible to every void orl class
    public AppStore.Category last_category = null;
    public AppStore.App? last_app = null;
    public PageType? current_page = null;
    public PageType? last_page = null;
    
    public enum PageType {
        HOMEPAGE,
        CATEGORIESVIEW,
        APPSVIEW,
        APPSINFO,
        UPDATESVIEW,
        ERRORPAGE;
        
        public string to_string () {
            switch (this) {
                case HOMEPAGE:
                    return _("Home Page");
                case CATEGORIESVIEW:
                    return _("Categories View");
                case APPSVIEW:
                    return _("Apps View");
                case APPSINFO:
                    return _("Apps Info");
                case UPDATESVIEW:
                    return _("Updates View");
                case ERRORPAGE:
                    return _("Error page");
                default:
                    assert_not_reached();
            }
        }
        
        public PageType[] get_all () {
            return { HOMEPAGE, CATEGORIESVIEW, APPSVIEW, APPSINFO, UPDATESVIEW, ERRORPAGE };
        }
    }
    
    // Apps Manager which handle the PackageKit connection
    public AppStore.AppsManager apps_manager;
    
    public class MainWindow : Gtk.Window {
        // Widgets
        public Box main_box;
        public MainToolbar toolbar;
        public PagesView pages_view;
        public ProgressInfo progress_info;
        
        // Vars
        private int _width = 0;
        
        // Signals
        public signal void choosed (AppStore.ResponseId id, AppStore.ModelApp app);
        
        public MainWindow (AppCenter app) {
            set_application (app);
            
            // If the database does not exist let's create one
            if (! FileUtils.test (Utils.database_path, FileTest.EXISTS))
                apps_manager.build_database ();
            
            window_position = WindowPosition.CENTER;
            title = "AppCenter Fedora";
            icon_name = "system-software-installer";
            set_default_size(640, 400);
            has_resize_grip = true;
            restore_saved_state ();
            main_box = new Box(Orientation.VERTICAL, 0);
            
            /* Gtk Actions and UIManager */
            main_actions = new Gtk.ActionGroup ("MainActionGroup");
            main_actions.set_translation_domain (Constants.GETTEXT_PACKAGE);
            main_actions.add_actions (main_entries, this);
            
            ui = new Gtk.UIManager ();

            try {
                ui.add_ui_from_string (ui_string, -1);
            }
            catch(Error e) {
                error ("Couldn't load the UI: %s", e.message);
            }

            Gtk.AccelGroup accel_group = ui.get_accel_group();
            add_accel_group (accel_group);

            ui.insert_action_group (main_actions, 0);
            ui.ensure_update ();             
            
            /* Toolbar */
            toolbar = new MainToolbar();
            
            /* SearchBar */
            toolbar.searchbar.text_changed_pause.connect((text) => { 
                if (toolbar.searchbar.text != "")
                    load_packages_from_string (text);
                else /*if (toolbar.searchbar.has_focus && toolbar.searchbar.text == "")*/ { 
                    if (current_page == PageType.ERRORPAGE)
                        pages_view.go_back ();
                }
                // If there are no matches found show an error message
                if (pages_view.apps_view.is_empty () && current_page == PageType.APPSVIEW) {
                    pages_view.set_page (PageType.ERRORPAGE);
                    pages_view.error_page.set_error_type (Pages.ErrorType.NO_MATCH_FOUND, toolbar.searchbar.text);
                }
                // Update last category
                //var category = new AppStore.Category (text, "\"" + text + "\"", _("Looking for: ") + text, "");
                //last_category = category;
            });
            toolbar.searchbar.activate.connect (() => {
                pages_view.apps_view.apps_tree.activate_first ();
            });
            /* AppMenu */
            var menu = ui.get_widget ("ui/AppMenu") as Gtk.Menu;
            
            var appmenu = app.create_appmenu (menu);
            toolbar.insert (appmenu, -1);
            
            main_box.pack_start(toolbar, false, false, 0);
            
            progress_info = new ProgressInfo ();
            
            main_box.pack_start (progress_info, false, false, 0);
            
            pages_view = new PagesView ();
            
            main_box.pack_start (pages_view, true, true, 0);
            
            connect_signals ();
            apps_manager.get_categories ();
            
            add (main_box);
            show_all ();
            
            progress_info.set_visible (false);
            
            set_focus (null);
            
            // Set HomePage as default page
            pages_view.set_page (PageType.HOMEPAGE);
            
            // Handle package context option
            // If the user wants to show a specif app at startup
            // Let's show it
            if (app.opening_package != null) {
                if (apps_manager.load_app_from_id (app.opening_package))
                    pages_view.set_page (PageType.APPSINFO);
            }
        }
        
        private void restore_saved_state () {

            default_width = saved_state.window_width;
            default_height = saved_state.window_height;

            if (saved_state.window_state == AppCenterWindowState.MAXIMIZED)
                maximize ();
            else if (saved_state.window_state == AppCenterWindowState.FULLSCREEN)
                fullscreen ();

        }

        private void update_saved_state () {

            // Save window state
            if (get_window ().get_state () == Gdk.WindowState.MAXIMIZED)
                saved_state.window_state = AppCenterWindowState.MAXIMIZED;
            else if (get_window ().get_state () == Gdk.WindowState.FULLSCREEN)
                saved_state.window_state = AppCenterWindowState.FULLSCREEN;
            else
                saved_state.window_state = AppCenterWindowState.NORMAL;

            // Save window size
            if (saved_state.window_state == AppCenterWindowState.NORMAL) {
                int width, height;
                get_size (out width, out height);
                saved_state.window_width = width;
                saved_state.window_height = height;
            }

        }
        
        protected override bool delete_event (Gdk.EventAny event) {
            update_saved_state ();
            return false;
        }
        
        public void on_choosed (AppStore.ResponseId id, AppStore.ModelApp app) {
            if (id == AppStore.ResponseId.INFO)
                load_details (app);
        }
        
        public void load_details (AppStore.ModelApp app) {
            apps_manager.get_details (app);
            pages_view.set_page(PageType.APPSINFO);
        }
        
        public void on_page_changed (PageType current, PageType old) {
            debug ("%u -> %u", old, current);
            // Clear search bar
            if (current != PageType.APPSVIEW && current != PageType.APPSINFO && current != PageType.ERRORPAGE)
                toolbar.searchbar.text = "";
            // Update history
            current_page = current;
            last_page = old;
            // Update navigation button
            toolbar.update_label (last_page, current_page);
        }
        
        public void load_packages_from_category (AppStore.Category category) {
            last_category = category;
            pages_view.set_page (PageType.APPSVIEW);
            pages_view.apps_view.apps_tree.clear ();
            apps_manager.get_apps (category.id);
        }
        
        public void load_packages_from_string (string id) {
            pages_view.apps_view.apps_tree.clear ();
            apps_manager.search_for_apps_global (id);
            pages_view.set_page (PageType.APPSVIEW);
        }
        
        public void on_action_response (AppStore.ActionType type, string id) {
            // Say to unity progress bar that another job is pending
            unity.append_job ();
            // Check what to do     
            switch (type) {
                case AppStore.ActionType.INSTALL:
                    apps_manager.install_package (id);
                    break;
                default:
                    apps_manager.remove_package (id, true, false);
                    break;
            }
        }
        
        /*public void update_back_button (Notebook nb, Widget pg, uint page_n) {
            GLib.debug ("Page->%s\n", ((PageType) page_n).to_string());
            switch ((PageType) page_n) {
                case PageType.HOMEPAGE:
                    toolbar.navigation_button.set_visible (false);
                    break;
                    
                case PageType.CATEGORIESVIEW:
                    toolbar.navigation_button.set_visible (false);
                    break;
                
                case PageType.APPSINFO:
                    toolbar.navigation_button.set_visible (true);
                    break;
                
                default:
                    toolbar.navigation_button.set_visible (true);
                    break;
            }
        }*/
        
        public void back_to_homepage () {
            pages_view.apps_view.apps_tree.clear ();
            pages_view.set_page (PageType.HOMEPAGE);
        }
        
        public void connect_signals () {
            // When an app is added
            apps_manager.app_added.connect (pages_view.apps_view.apps_tree.append_app);
            // When something start loading
            apps_manager.loading_started.connect(on_load_started);
            // When something stop loading
            apps_manager.loading_finished.connect(on_load_finished);
            // When a transaction progress
            apps_manager.loading_progress.connect(progress_info.set_progress);
            // When a category is found in the database
            apps_manager.category_added.connect(pages_view.categories_view.add_category);
            // When a Details object is found from a package
            apps_manager.details_received.connect(on_details_received);
            // When updates are loaded
            apps_manager.update_received.connect (pages_view.updates_view.update_received);
            // When an error is received
            apps_manager.error_received.connect (on_error_received);
            // When window is resized
            this.size_allocate.connect (on_size_allocate);
            // When a key button is pressed
            this.key_press_event.connect ((ev) => {
                if (!toolbar.searchbar.has_focus)
                    toolbar.searchbar.grab_focus ();
                return false;
            });
            // When either More Info is pressed or an app is double clicked show its details
            this.choosed.connect(on_choosed);
            // When a page is changed
            pages_view.page_changed.connect (on_page_changed);
            // When a category is clicked
            pages_view.categories_view.category_choosed.connect(load_packages_from_category);
            // When an app is selected
            pages_view.apps_view.apps_tree.activated_row.connect((a) => {
                this.choosed (0, a);
            });
            // When back is clicked
            toolbar.navigation_button.clicked.connect (on_back_clicked);
            // When AppsInfo's action button is pressed
            pages_view.apps_info.action_response.connect (on_action_response);
        }
        
        public void rework_categories_columns (int width) {
            if (_width != width && width/160 != pages_view.categories_view.columns) {
                GLib.debug ("Window.width->%d rework columns\n", width);
                int size = width;
                if (size < 160 ) {
                    size = 160;
                }
                pages_view.categories_view.columns = size/150;
                
                _width = width;
            }
        }
        
        public void on_error_received (AppStore.ErrorType type) {
            if (type == AppStore.ErrorType.COULD_NOT_GET_LOCK) {
                pages_view.set_page (PageType.ERRORPAGE);
                pages_view.error_page.set_error_type (Pages.ErrorType.COULD_NOT_GET_LOCK);
            }
        }
        
        public void on_size_allocate (Allocation alloc) {
            rework_categories_columns (alloc.width);
        }
        
        public void on_back_clicked () {
            if (pages_view.active == PageType.ERRORPAGE)
                pages_view.set_page (PageType.HOMEPAGE);
            else
                pages_view.set_page (toolbar.navigation_button.last_type ?? last_page);
        }
        
        public void on_load_started (AppStore.LoadingType load, string comment) {
            switch (load) {
                case AppStore.LoadingType.PACKAGES:
                    progress_info.load (comment);
                    break;
                case AppStore.LoadingType.DETAILS:
                    pages_view.apps_info.start_load();
                    break;
                case AppStore.LoadingType.INSTALL:
                    progress_info.load_from_action (last_app.name, load);
                    break;
                case AppStore.LoadingType.REMOVE:
                    progress_info.load_from_action (last_app.name, load);
                    break;
                default:
                    break;
            }
        }
        
        public void on_load_finished (AppStore.LoadingType load) {
            // Clear unity progress bar
            unity.clear ();
            // Check what to do
            switch (load) {
                case AppStore.LoadingType.CATEGORIES:
                    rework_categories_columns(get_allocated_width ());
                    break;
                case AppStore.LoadingType.PACKAGES:
                    progress_info.clear();
                    break;
                case AppStore.LoadingType.DETAILS:
                    progress_info.clear();
                    break;
                default:
                    progress_info.clear();
                    break;
            }
        }
        
        public void on_details_received (AppStore.App app) {
            pages_view.apps_info.set_details (app);
        }
        
        // Actions
        void action_quit () {
            destroy ();
        }
        
        // AppMenu actions
        void action_software_properties () {
            // Run "gpk-prefs"
            try {
                GLib.Process.spawn_command_line_async ("gpk-prefs");
            } catch (SpawnError e) {
                debug (e.message);
            }
        }
        
        static const Gtk.ActionEntry[] main_entries = {
           { "Quit", Gtk.Stock.QUIT,
          /* label, accelerator */       N_("Quit"), "<Control>q",
          /* tooltip */                  N_("Quit"),
                                         action_quit },
                                         
            // AppMenu actions
           { "SoftwareProperties", null,
          /* label, accelerator */       N_("Software Sources"), null,
          /* tooltip */                  N_("Edit source software"),
                                         action_software_properties }
        };
    }
}
