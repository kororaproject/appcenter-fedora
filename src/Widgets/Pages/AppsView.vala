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
using PackageKit;

namespace AppCenter.Widgets {
    public class AppsTree : TreeView {
        // Signals
        public signal void app_added (TreeIter iter);
        public signal void selected_row (AppStore.ModelApp app);
        public signal void activated_row (AppStore.ModelApp app);
        
        // Vars
        private IconTheme theme;
        private new ListStore model;
        private TreeIter iter;
        private new TreePath path;
        private new TreeSelection selection;
        
        public AppsTree () {
			theme = IconTheme.get_default ();
			theme.append_search_path ("/usr/share/app-install/icons");
			
			Type t_string = typeof (string);
            model = new ListStore (3,
                t_string, // Icon name
                t_string, // Name and description
                typeof (AppStore.ModelApp)  // id
            );
            
            set_model (model);
            
            selection = get_selection ();
            selection.mode = Gtk.SelectionMode.SINGLE;
            
            CellRendererPixbuf icon_cell = new CellRendererPixbuf ();
            icon_cell.height = 56;
            icon_cell.width = 56;
            icon_cell.stock_size = IconSize.DIALOG;
            
            CellRendererText text = new CellRendererText ();
            text.ellipsize = Pango.EllipsizeMode.END;
            
            insert_column_with_attributes (-1, "Icon", icon_cell, "icon-name", 0);
            insert_column_with_attributes (-1, "Name", text, "markup", 1);
            
            get_column (1).set_expand (true);
            get_column (1).clicked ();
            
            rules_hint = true;
            
            cursor_changed.connect(on_cursor_changed);
            selection.changed.connect (on_selection_changed);

            headers_visible = false;
        }
        
        public void append_app (AppStore.ModelApp app) {            
            
            // Do it better!
            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }
            
            model.append (out iter);
            model.set (iter, 0, app.icon, 1, "<b>"+Utils.escape_text (app.name)+"</b>\n"+Utils.escape_text (app.description), 2, app); 
            
            app_added (iter);
        }
        
        public void clear () {
            // FIXME: it is not cool to use that kind of hackish solutions
            selection.changed.disconnect (on_selection_changed);
            model.clear();
            selection.changed.connect (on_selection_changed);
        }
        
        public bool is_empty () {
            Gtk.TreeIter iter;
            return !model.get_iter_first (out iter);
        }
        
        public void on_cursor_changed (TreeView widget) {
            get_cursor(out path, null);
            if (path != null) {
                AppStore.ModelApp val;
                model.get_iter(out iter, path);
                model.get(iter, 2, out val);
                selected_row(val);
            }
        }
        
        public void on_selection_changed () {
            // Getting objects...
            Gtk.TreeIter? iter = null;
            Gtk.TreeModel? mod = null;
            selection.get_selected (out mod, out iter);
            var path = mod.get_path (iter);
            // Show selection
            get_cursor(out this.path, null);
            if (path != null) {
                AppStore.ModelApp val;
                model.get_iter(out iter, this.path);
                model.get(iter, 2, out val);
                activated_row(val);
            }
            // Clean selection
            selection.unselect_all ();
        }
        
        public void activate_first () {
            // Simulates an activation of the first item of the list
            // Getting objects...
            Gtk.TreeIter? iter = null;
            this.model.get_iter_first (out iter);
            // Show selection
            this.path = model.get_path (iter);
            if (path != null) {
                AppStore.ModelApp val;
                model.get_iter(out iter, this.path);
                model.get(iter, 2, out val);
                activated_row(val);
            }
            // Clean selection
            selection.unselect_all ();
        }
       
    }
    
    public class AppsView : Box {
        // Widgets
        public AppsTree apps_tree;
        
        public AppsView () {
            orientation = Orientation.VERTICAL;
            
            apps_tree = new AppsTree ();
            
            ScrolledWindow apps_tree_scroll = new ScrolledWindow (null, null);
            apps_tree_scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            apps_tree_scroll.add (apps_tree);
            apps_tree_scroll.scroll_child.connect (() => {
                debug ("");
                return false;
            });
            
            pack_start (apps_tree_scroll, true, true, 0);
        }
        
        public bool is_empty () {
            return apps_tree.is_empty ();
        }
    }
}
