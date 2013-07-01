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
    public class InfoMessage : InfoBar {
        private uint timeout_id = 0;
        // Signals
        public signal void choosed (AppStore.ResponseId id, AppStore.ModelApp app);
        
        // Widgets
        public Label text;
        public Button info_button;
        public Button action_button;
        private AppStore.ModelApp current_app;
        
        public void update (AppStore.ModelApp app) {
            current_app = app;
            set_visible (true);
            text.set_label("Selected package <b>%s</b>".printf (app.id));
            
            if (timeout_id > 0)
                Source.remove (timeout_id);
            
            timeout_id = Timeout.add (2500, () => {
                set_visible (false);
                return false;
            });
        }
        
        public void get_response (InfoBar bar, int id) {
            choosed ((AppStore.ResponseId) id, current_app);
        }
        
        public InfoMessage () {
            message_type = MessageType.INFO;
            ((Box) get_action_area()).orientation = Orientation.HORIZONTAL;
            Box main = get_content_area() as Box;
            main.orientation = Orientation.HORIZONTAL;
            main.spacing = 2;
            orientation = Orientation.HORIZONTAL;
            
            text = new Label("");
            text.use_markup = true;
            text.ellipsize = Pango.EllipsizeMode.END;
            
            add_button(Stock.INFO, AppStore.ResponseId.INFO);
            
            main.pack_start(text, false, false, 0);
            
            response.connect (get_response);
        }
    }
}
