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
using AppCenter.Pages;

namespace AppCenter.Widgets {
    public class PagesView : Notebook {
        public HomePage home_page;
        public CategoriesView categories_view;
        public AppsView apps_view;
        public AppsInfo apps_info;
        public UpdatesView updates_view;
        public ErrorPage error_page;
        
        public PageType? active = null;
        
        public signal void page_changed (PageType current, PageType old);
        
        public void set_page (PageType page) {
            // Update history
            last_page = (PageType) get_current_page ();
            debug ("%u", last_page);
            // Let's go to the future
            if (page == get_current_page ()) {
                switch_page (get_nth_page((int)page), page);
            } else {
                set_current_page (page);
            }
            active = page;
            // Emit...
            page_changed (page, last_page ?? PageType.HOMEPAGE);
        }
        
        public void go_back () {
            set_page (last_page);
        }
        
        public PagesView () {
            show_border = false;
            show_tabs = false;
            
            home_page = new HomePage ();
            // Add a category button by default
            var categories_button = new HomeButton (_("Categories"), _("Browser apps in categories"), "applications-other");
            categories_button.clicked.connect (() => {
                set_page (PageType.CATEGORIESVIEW);
            });
            home_page.append_button (categories_button);
            ScrolledWindow home_page_scroll = new ScrolledWindow (null, null);
            home_page_scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            home_page_scroll.add_with_viewport (home_page);
            ((Viewport)home_page_scroll.get_child()).set_shadow_type (ShadowType.NONE);
            append_page (home_page_scroll, null);
            
            categories_view = new CategoriesView ();
            append_page (categories_view, null);
            
            apps_view = new AppsView ();
            append_page (apps_view, null);
            
            apps_info = new AppsInfo ();
            /*ScrolledWindow apps_info_scroll = new ScrolledWindow(null, null);
            apps_info_scroll.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
            apps_info_scroll.add_with_viewport(apps_info);
            ((Viewport)apps_info_scroll.get_child()).set_shadow_type (ShadowType.NONE);*/
            append_page (apps_info, null);
            
            updates_view = new UpdatesView ();
            append_page (updates_view, null);
            
            error_page = new ErrorPage ();
            append_page (error_page, null);
        }
    }
}
