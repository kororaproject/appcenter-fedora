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
using AppCenter.Widgets;

namespace AppCenter.Pages {
    public class HomeButton : Button {
        
        private Image icon_image;
        
        public HomeButton (string title, string description, string icon) {
            can_focus = false;
            set_relief (ReliefStyle.NONE);
            
            var main_box = new Box (Orientation.HORIZONTAL, 3);
            var text_box = new Box (Orientation.VERTICAL, 3);
            text_box.halign = Align.START;
            
            var title_label = new Label (Markup.printf_escaped ("<span weight='medium' size='11700'>%s</span>", title));
            title_label.use_markup = true;
            title_label.ellipsize = Pango.EllipsizeMode.END;
            title_label.halign = Align.START;
            title_label.valign = Align.START;
            
            var description_label = new Label (Markup.printf_escaped ("<span weight='medium' size='11400'>%s</span>", description));
            description_label.use_markup = true;
            description_label.ellipsize = Pango.EllipsizeMode.END;
            description_label.halign = Align.START;
            description_label.valign = Align.START;
            description_label.sensitive = false;
            
            var pixbuf = Utils.get_pixbuf_from_icon_name (icon, 64);
            if (pixbuf != null)
                icon_image = new Image.from_pixbuf (pixbuf);
            else
                icon_image = new Image.from_icon_name (icon, IconSize.DIALOG);
            icon_image.halign = Align.START;
            
            text_box.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // Top spacing
            text_box.pack_start (title_label, false, false, 0);
            text_box.pack_start (description_label, false, false, 0);
            text_box.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // Bottom spacing
            
            main_box.pack_start (icon_image, false, true, 0);
            main_box.pack_start (text_box, false, true, 0);
        
            this.add (main_box);
            this.show_all ();
        }
        
        public void set_icon_from_pixbuf (Gdk.Pixbuf pixbuf) {
            icon_image.set_from_pixbuf (pixbuf);
        }
        
    }
    
    public class HomePage : BlankBox {
        
        private Box banner_box;
        private Box apps_box;
        private Grid apps_grid;

        private int n_columns = 1; // Two columns
        private int left = 0; // No more than 1
        private int top = 0; // No more than 1
        private int width = 1; // Event 1
        private int height = 1; // Event 1
        
        public HomePage () {
            base (Orientation.VERTICAL, 5, 5);
            
            // Add content-view styling
            get_style_context().add_class (Granite.StyleClass.CONTENT_VIEW);
            
            // Banners
            banner_box = new Box (Orientation.HORIZONTAL, 5);

            // Apps
            apps_box = new Box (Orientation.VERTICAL, 5);
            
            apps_grid = new Grid ();
            apps_grid.row_spacing = 5;
            apps_grid.column_spacing = 5;
            apps_grid.row_homogeneous = true;
            apps_grid.column_homogeneous = true;
            
            apps_box.pack_start (apps_grid, true, true, 5);
        
            //pack_start (banner_box, true, true, 0); It's too early
            pack_start (apps_box, true, true, 0);
            
            // Add only a category button by default
        }

        public void append_banner (Widget banner) {
            banner_box.pack_start (banner, true, true, 0);
        }
        
        public void append_button (Widget button) {
            if (left > n_columns)
                left = 0;
                
            apps_grid.attach (button, left, top, width, height);
            
            button.show ();
            
            if (left == n_columns) top++;
            left++;
        }
    }
}
