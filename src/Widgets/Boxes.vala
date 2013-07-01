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
using Cairo;

namespace AppCenter.Widgets {
    public class BlankBox : EventBox {
        private Cairo.Context cr;
        private Box container;
        
        public BlankBox (Orientation or, int spacing, int border_width) {
            set_has_window(false);
            
            container = new Box(or, spacing);
            container.border_width = border_width;
            
            add(container);
        }
        
        public void show_children () {
            container.foreach((c) => {
                c.set_visible (true);
            });
        }
        
        public void hide_children () {
            container.foreach((c) => {
                c.set_visible (false);
            });
        }
        
        public void pack_start (Widget widget, bool expand, bool fill, int space) {
            container.pack_start(widget, expand, fill, space);
        }
        
        private void draw_rectangle (uint x, uint y, int width, int height) {
            Gdk.RGBA color;
            color = { 255, 255, 255, 1 };
            
            Gdk.cairo_set_source_rgba (cr, color);
            
            cr.new_path();
            cr.rectangle (x, y, width, height);
            cr.close_path ();
            
            cr.fill();
        }
        
        public override bool draw (Cairo.Context cr) {
            this.cr = cr;
            
            int width = get_allocated_width ();
            int height = get_allocated_height ();
            
            draw_rectangle(0, 0, width, height);
            
            return base.draw(cr);
        }
    
        public override void size_allocate (Allocation allocation) {
            base.size_allocate (allocation);
        }
    }
    
    public class RoundBox : EventBox {
        private Cairo.Context cr;
        private Box container;
        
        private enum Colors {
            BACKGROUND,
            BORDER
        }
        
        public RoundBox (Orientation or, int spacing) {
            set_has_window(false);
            
            container = new Box(or, spacing);
            
            add(container);
        }
        
        public void pack_start (Widget widget, bool expand, bool fill, int space) {
            container.pack_start(widget, expand, fill, space);
        }
        
        private void draw_rounded_rectangle (Colors rgb, uint x, uint y, int width, int height, double radius) {
            Gdk.RGBA color;
            bool res;
            if (rgb == Colors.BACKGROUND) {
                //res = get_style_context().lookup_color("base_color", out color);
                color = { 255, 255, 255, 1 };
                res = true;
            } else {
                color = { 0.8, 0.8, 0.8, 1 };
                res = true;
            }
            
            if (res == false) {
                color = { 0, 0, 0, 0 };
            }
            
            Gdk.cairo_set_source_rgba (cr, color);
            
            cr.new_path();
            cr.move_to (x + radius, y);
            cr.arc (width - x - radius, y + radius, radius, Math.PI * 1.5, Math.PI * 2);
            cr.arc (width - x - radius, height - y - radius, radius, 0, Math.PI * 0.5);
            cr.arc (x + radius, height - y - radius, radius, Math.PI * 0.5, Math.PI);
            cr.arc (x + radius, y + radius, radius, Math.PI, Math.PI * 1.5);
            cr.close_path ();
            
            cr.fill();
        }
        
        public override bool draw (Cairo.Context cr) {
            this.cr = cr;
            
            int width = get_allocated_width ();
            int height = get_allocated_height ();
            double arc_radius = 10.0;
            
            draw_rounded_rectangle(Colors.BORDER, 0, 0, width, height, arc_radius);
            draw_rounded_rectangle(Colors.BACKGROUND, 1, 1, width, height, arc_radius-1);
            
            return base.draw(cr);
        }
    
        public override void size_allocate (Allocation allocation) {
            base.size_allocate (allocation);
        }
    }
}
