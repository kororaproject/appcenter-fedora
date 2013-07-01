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
using AppCenter.Utils;

namespace AppCenter.Widgets {
    public class  GridView : BlankBox {
        // Widgets
        public Box container;
        private Label title_label;
        
        // Vars
        public string title {
            set {
                title_label.label = "<span size='large'><b>"+Utils.escape_text (value)+"</b></span>";
            }
        }
        
        public void grid_pack_start (Widget widget, bool expand, bool fill, int space) {
            container.pack_start(widget, expand, fill, space);
        }
        
        public GridView (string title) {
            base(Orientation.VERTICAL, 0, 12);
            
            container = new Box(Orientation.VERTICAL, 6);
            container.margin_top = 6;
            
            title_label = new Label("");
            title_label.use_markup = true;
            title_label.halign = Align.START;
            
            this.title = title;
            
            pack_start(title_label, false, false, 0);
            pack_start(container, false, false, 0);
        }
    }
}
