// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/***
  BEGIN LICENSE

  Copyright (C) 2012-2013 Mario Guerriero <mario@elementaryos.org>
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

namespace AppCenter {
    public class ScreenshotFactory : GLib.Object {
        // Return 800x600 screenshot
        public static async Gdk.Pixbuf? get_screenshot_pixbuf_from_package_name (string package_name) {
            Gdk.Pixbuf? pix = null;
            
            var file = File.new_for_uri ("http://screenshots.debian.net/screenshot/" + package_name);

            try {            
                GLib.InputStream @input_stream = yield file.read_async (Priority.DEFAULT, null);
                pix = yield new Gdk.Pixbuf.from_stream_at_scale_async (input_stream, 800, 600, true, null);
            } catch (Error e) {
                warning (e.message);
            }

            return pix;
        }
        
    }
    
    public class ScreenshotWidget : Gtk.Box {
        
        private Gtk.DrawingArea area;
        private Granite.Widgets.LightWindow? light_window = null;
        private Pango.Layout layout;
        private Gtk.Spinner spinner;
        private Gdk.Pixbuf? pixbuf = null;
        
        public ScreenshotWidget () {
            this.set_size_request (settings.screenshot_width, settings.screenshot_height);
            
            area = new Gtk.DrawingArea ();
            area.add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK);
            area.hexpand = true;
            area.vexpand = true;
            area.app_paintable = true;
            // Change mouse pointer style when hovering
            area.enter_notify_event.connect (() => {
                if (pixbuf != null)
                    area.get_window ().set_cursor (new Gdk.Cursor (Gdk.CursorType.PLUS));
                else
                    area.get_window ().set_cursor (new Gdk.Cursor (Gdk.CursorType.LEFT_PTR));
                return true;
            });
            area.draw.connect (on_draw);
            area.button_press_event.connect (on_button_press);
            
            layout = area.create_pango_layout (_("No screenshot was found"));
            
            spinner = new Gtk.Spinner ();
            spinner.set_size_request(64, 64);
            spinner.active = true;
            spinner.hexpand = true;
            spinner.vexpand = true;
            spinner.halign = Gtk.Align.CENTER;
            spinner.valign = Gtk.Align.CENTER;

            pack_start (area, true, true, 0);
            pack_start (spinner, false, false, 0);
            
            show_all ();

        }
        
        private bool on_draw (Cairo.Context ctx) {
            // Get drawing area allocation
            Gtk.Allocation allocation;
            area.get_allocation (out allocation);
            int width = allocation.width;
            int height = allocation.height;

            // Draw some fallback things if there isn't a real screenshot
            if (pixbuf == null) {
                // Set some stuffs
                var font = Pango.FontDescription.from_string ("Sans Bold");
                
                layout.set_font_description (font);
                
                // Show it
                int fontw, fonth;
                this.layout.get_pixel_size (out fontw, out fonth);
                ctx.move_to ((width - fontw) / 2,
                            (height - fonth) / 2);
                Pango.cairo_update_layout (ctx, this.layout);
                Pango.cairo_show_layout (ctx, this.layout);
                
                return true;
            }
            
            // Create a copy pixbuf and draw it scaled
            var copy_pixbuf = pixbuf.scale_simple (settings.screenshot_width, settings.screenshot_height, Gdk.InterpType.BILINEAR);
            
            // Draw pixbuf in the middle of the Context
            Gdk.cairo_set_source_pixbuf (ctx, copy_pixbuf, 
                                        ((width - copy_pixbuf.get_width ())/2), 
                                        ((height - copy_pixbuf.get_height ())/2));

            ctx.paint ();
            
            stop_spinner ();
            
            return true;
        }        
        
        private bool on_button_press (Gdk.EventButton event) {
            // Left button
            if (event.button == 1) {
                if (pixbuf != null && light_window == null) {
                    light_window = new Granite.Widgets.LightWindow (last_app.name);
                    light_window.window_position = Gtk.WindowPosition.CENTER;
                    var image = new Gtk.Image.from_pixbuf (pixbuf);
                    light_window.add (image);
                    light_window.show_all ();
                    light_window.destroy.connect (() => {
                        light_window = null;
                    });
                }
            }
            
            return false;
        }
        
        public void start_spinner () {
            area.set_visible (false);
            spinner.set_visible (true);

            spinner.start ();
        }
        
        public void stop_spinner () {
            area.set_visible (true);
            spinner.set_visible (false);
            
            spinner.stop ();
        }
        
        public void set_pixbuf (Gdk.Pixbuf? pix) {
            this.pixbuf = pix;
            start_spinner ();
            queue_draw ();
        }
    }
}
