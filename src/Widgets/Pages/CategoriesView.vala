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

namespace AppCenter.Widgets {   
    public class CategoryButton : Button {
        private AppStore.Category desc;
        public signal void category_clicked (AppStore.Category cat);
        
        private bool emit_clicked (Widget box, Gdk.EventButton button) {
            category_clicked (desc);
            return true;
        }
        
        public CategoryButton (AppStore.Category desc, bool fill = false) {
            this.desc = desc;
            
            sensitive = ! fill;
            can_focus = false;
            set_relief (ReliefStyle.NONE);
            
            if (desc.icon != "" && ! fill) {
                Box container = new Box(Orientation.HORIZONTAL, 6);
                //container.border_width = 5;
                Box label_box = new Box (Orientation.VERTICAL, 0);
                label_box.valign = Align.CENTER;

                // Make categories names translatable and apply the correct icon
                string title_string = "%s".printf (desc.name);
                string icon_name = desc.icon;
                
                switch (desc.name) {
                    case "Accessories":
                        title_string = _("Accessories");
                        break;
                    case "Universal Access":
                        title_string = _("Universal Access");
                        break;
                    case "Programming":
                        title_string = _("Programming");
                        break;
                    case "Education":
                        title_string = _("Education");
                        icon_name = "applications-education";
                        break;
                    case "Science":
                        title_string = _("Science");
                        break;
                    case "Games":
                        title_string = _("Games");
                        break;
                    case "Graphics":
                        title_string = _("Graphics");
                        break;
                    case "Internet":
                        title_string = _("Internet");
                        break;
                    case "Sound & Video":
                        title_string = _("Sound & Video");
                        break;
                    case "Office":
                        title_string = _("Office");
                        break;
                    case "System Tools":
                        title_string = _("System Tools");
                        break;
                    case "Other":
                        title_string = _("Other");
                        break;
                }
                
                Image image_widget = new Image.from_icon_name (icon_name, IconSize.DIALOG);
                image_widget.set_size_request (48, 48);
                
                Label title = new Label (title_string);
                title.ellipsize = Pango.EllipsizeMode.END;
                title.halign = Align.START;
                title.valign = Align.END;
                
                tooltip_text = desc.summary;
                
                Label description = new Label(_("<i>%d apps</i>").printf (desc.records));
                description.ellipsize = Pango.EllipsizeMode.END;
                description.halign = Align.START;
                description.valign = Align.START;
                description.use_markup = true;
                description.sensitive = false;
                
                label_box.pack_start(title, false, false, 0);
                label_box.pack_start(description, false, false, 0);
                
                container.pack_start(image_widget, false, false, 0);
                container.pack_start(label_box, false, false, 0);
                add(container);
                
                button_press_event.connect(emit_clicked);
            }
            
            if (desc.id == "")
                sensitive = false;
        }
    }
    
    public class CategoriesView : GridView {
        public signal void category_choosed (AppStore.Category cat);
        
        // Vars
        private Box box_child;
        private CategoryButton button_child;
        public int columns { get; set; }
        private int actual_col;
        private new List<AppStore.Category> children = null;
        
        public void add_category (AppStore.Category cat) {
            children.append (cat);
        }
        
        public void reconfigure_grid () {
            foreach (Widget widget in container.get_children()) {
                container.remove(widget);
            }
            
            box_child = null;
            actual_col = columns;
            
            foreach (AppStore.Category button_desc in children) {
                if (actual_col == columns) {
                    box_child = new Box(Orientation.HORIZONTAL, 6);
                    box_child.homogeneous = true;
                    box_child.show();
                    grid_pack_start(box_child, true, true, 0);
                    actual_col = 0;
                }
                button_child = new CategoryButton (button_desc);
                button_child.category_clicked.connect ((i) => {
                    category_choosed (i);
                });
            
                box_child.pack_start (button_child, true, true, 0);
                button_child.show_all ();
                
                actual_col++;
            }
            
            while (actual_col != columns) {
                button_child = new CategoryButton(new AppStore.Category("", "", "", "", 0), true);
                box_child.pack_start(button_child, true, true, 0);
                button_child.show_all();
                actual_col++;
            }
        }
        
        public CategoriesView () {
            base(_("Categories"));
            columns = 0;
            actual_col = 0;
            
            // Style
            get_style_context().add_class (Granite.StyleClass.CONTENT_VIEW);
            
            box_child = new Box(Orientation.HORIZONTAL, 6);
            box_child.homogeneous = true;
            grid_pack_start(box_child, true, true, 0);
            
            notify["columns"].connect(reconfigure_grid);
        }
    }
}
