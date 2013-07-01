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
using Granite.Widgets;
using AppCenter.Utils;

namespace AppCenter.Widgets {
    public class MainToolbar : Toolbar {
        // Widgets
        private ToolItem tool;
        public Image icon;
        public NavigationButton navigation_button;
        public SearchBar searchbar;
        
        public void update_label (PageType old, PageType current) {

            switch (old) {
                case PageType.HOMEPAGE:
                    navigation_button.set_history (_("Home Page"), old);
                    break;
                case PageType.CATEGORIESVIEW:
                    navigation_button.set_history (_("Categories"), old);
                    break;
                case PageType.APPSVIEW:
                    if (searchbar.text != "" && searchbar.text != null)
                        navigation_button.set_history ("\"" + searchbar.text + "\"", old);
                    if (last_category != null)
                        navigation_button.set_history (last_category.name, PageType.APPSVIEW);
                    else
                        navigation_button.set_history (_("Home Page"), PageType.HOMEPAGE);                    
                    break;
                case PageType.APPSINFO:
                    navigation_button.set_history (_("Home Page"), PageType.HOMEPAGE);
                    break;
            }
            
            // Hide navigation_button when it's not needed
            navigation_button.set_visible (!(current == PageType.HOMEPAGE));
            
            if (current == PageType.CATEGORIESVIEW)
                navigation_button.set_history (_("Home Page"), PageType.HOMEPAGE);
            
            if (current == old && current == PageType.APPSVIEW)
                navigation_button.set_history (_("Home Page"), PageType.HOMEPAGE);
            
            if (current == PageType.APPSINFO) {
                last_category = null;
                if (searchbar.text != "" && searchbar.text != null)
                    navigation_button.set_history ("\"" + searchbar.text + "\"", old);
            }
        }
        
        private void insert_with_tool (Widget widget, int pos) {
            tool = new ToolItem();
            tool.margin_left = 5;
            tool.add(widget);
            insert(tool, pos);
        }
        
        public MainToolbar () {
            get_style_context().add_class("primary-toolbar");
            
            toolbar_style = ToolbarStyle.BOTH_HORIZ;
            show_arrow = false;
            
            // Navigation button
            navigation_button = new NavigationButton ();
            
            insert_with_tool (navigation_button, -1);
            
            ToolItem space_item = new ToolItem();
            space_item.set_expand(true);
            insert(space_item, -1);
            
            searchbar = new SearchBar(_("Search Apps"));
            searchbar.margin = 5;
            insert_with_tool(searchbar, -1);
        }

    }
}

