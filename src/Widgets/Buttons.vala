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

namespace AppCenter.Widgets {

    public class ActionButton : Gtk.Button {
        
        const string STYLESHEET = 
        """
        .blue-button {
            -unico-inner-stroke-width: 1px 0 1px 0;

            background-image: -gtk-gradient (linear,
                            left top,
                            left bottom,
                            from (shade (@selected_bg_color, 1.30)),
                            to (shade (@selected_bg_color, 0.98)));

            -unico-border-gradient: -gtk-gradient (linear,
                            left top, left bottom,
                            from (shade (@selected_bg_color, 1.05)),
                            to (shade (@selected_bg_color, 0.88)));

            -unico-inner-stroke-gradient: -gtk-gradient (linear,
                            left top, left bottom,
                            from (alpha (#fff, 0.30)),
                            to (alpha (#fff, 0.06)));
        }

        .red-button {
            -unico-inner-stroke-width: 1px 0 1px 0;
            
            background-image: -gtk-gradient (linear,
				     left top,
				     left bottom,
                     from (#e56453),
                     to (#bb2332));

            -unico-border-gradient: -gtk-gradient (linear,
                             left top, left bottom,
                             from (#dd3b27),
                             to (#791235));
          
            -unico-inner-stroke-gradient: -gtk-gradient (linear,
                            left top, left bottom,
                            from (alpha (#fff, 0.30)),
                            to (alpha (#fff, 0.06)));
        }
        """;
        
        private Gtk.CssProvider style_context;
        
        private AppStore.ActionType action_type;
        
        // Content widgets
        private Gtk.Box container;
        private Gtk.Image icon;
        private Gtk.Label text;
        
        // Pixbufs
        private Gdk.Pixbuf install_pixbuf;
        private Gdk.Pixbuf remove_pixbuf;
        
        public ActionButton () {
            // Style context
            style_context = new Gtk.CssProvider ();
            
            try {
                style_context.load_from_data (STYLESHEET, -1);
            } catch (GLib.Error e) {
                warning (e.message);
            }
            
            this.get_style_context ().add_provider (style_context, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
            this.get_style_context ().add_class ("raised");
            
            // Content
            container = new Gtk.Box (Orientation.HORIZONTAL, 3);
            
            icon = new Gtk.Image ();
            
            text = new Gtk.Label ("");
            text.use_markup = true;
            text.margin_right = 10; 
            
            container.pack_start (icon, true, true, 5);
            container.pack_start (text, true, true, 5);
            
            this.add (container);
            
            // Pixbufs
            install_pixbuf = Utils.get_pixbuf_with_colour ("browser-download-symbolic");
            if (install_pixbuf == null) {
                install_pixbuf = Utils.get_pixbuf_from_path (Utils.install_icon_filename);
            }
            remove_pixbuf = Utils.get_pixbuf_with_colour ("user-trash-symbolic");
            if (remove_pixbuf == null) {
                remove_pixbuf = Utils.get_pixbuf_from_path (Utils.remove_icon_filename);
            }
        }
        
        public void set_text (string text) {
            this.text.set_markup ("<span foreground='white'>" + text + "</span>");
        }
        
        public void set_image_from_pixbuf (Gdk.Pixbuf pixbuf) {
            icon.set_from_pixbuf (pixbuf);
        }
        
        public void set_action_type (AppStore.ActionType type) {
            if (type == AppStore.ActionType.INSTALL) {
                // Blue style
                this.get_style_context ().remove_class ("red-button");
                this.get_style_context ().add_class ("blue-button");
                
                this.set_text (_("Install"));
                this.set_image_from_pixbuf (install_pixbuf);
            }
            else if (type == AppStore.ActionType.REMOVE) {
                // Red style
                this.get_style_context ().remove_class ("blue-button");
                this.get_style_context ().add_class ("red-button");
            
                this.set_text (_("Remove"));
                this.set_image_from_pixbuf (remove_pixbuf);
            }
            this.action_type = type;
        }

    }
    
    public class NavigationButton : Gtk.Button {
        
        private Gtk.Label text;
        
        public PageType? last_type = null;
        private PageType[]? types = null;
        
        public NavigationButton () {
            can_focus = false;
            valign = Align.CENTER;
            vexpand = false;
            
            Box button_b = new Box(Orientation.HORIZONTAL, 0);
            var icon = new Image.from_icon_name ("go-previous-symbolic", Gtk.IconSize.MENU);
            text = new Gtk.Label ("");
            
            button_b.pack_start (icon, true, true, 2);
            button_b.pack_start (text, true, true, 2);
           
            this.add (button_b);
        }
        
        public string get_text () {
            return text.label;
        }
        
        public void set_history (string text, PageType type) {
        
            if (types == null)
                type.get_all ();
           
            // If the text is from a search result...
            this.text.label = text;
            this.last_type = type;
            
        }
    
    }
}
