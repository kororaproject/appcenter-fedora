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
    
    public class ProgressInfo : InfoBar {
        // Widgets
        public Label text;
        public ProgressBar progress_bar;
        public Spinner spin;
        
        public void set_progress (int progress_percentage) {
			int percentage = progress_percentage / 2;
			// Update unity progress
			unity.set_progress (percentage / 100.0);
			// Update infobar percentage
			if (last_app != null)
			    debug (last_app.name);
			if (progress_bar.get_fraction () != percentage / 100.0) {
				spin.set_visible (false);
				progress_bar.set_visible (true);
				progress_bar.set_fraction (percentage / 100.0);
			}
 	    }
        
        public void load (string label_text) {
            show_all ();
            text.set_label (label_text);
            progress_bar.set_visible (false);
            spin.set_visible (true);
            spin.start ();
        }
        
        public void load_from_action (string app, AppStore.LoadingType action) {
            show_all ();
            
            string label_text = "";
            
            if (action == AppStore.LoadingType.INSTALL)
                label_text = _("Installing") + " <b>" + app + "</b>...";
            else if (action == AppStore.LoadingType.REMOVE)
                label_text = _("Removing") + " <b>" + app + "</b>...";

            text.set_markup (label_text);
            
            progress_bar.set_visible (false);
            spin.set_visible (true);
            spin.start ();
        }
        
        public void clear () {
            spin.stop();
            progress_bar.set_fraction(0.0);
            set_visible(false);
        }
        
        public ProgressInfo () {
            message_type = MessageType.INFO;
            Box main = get_content_area () as Box;
            main.orientation = Orientation.HORIZONTAL;
            main.spacing = 2;
            orientation = Orientation.HORIZONTAL;
            
            text = new Label ("");
            text.use_markup = true;
            text.ellipsize = Pango.EllipsizeMode.END;
            
            progress_bar = new ProgressBar ();
            progress_bar.pulse_step = 0.1;
            
            spin = new Spinner ();
            
            main.pack_start (text, false, false, 0);
            main.pack_end (progress_bar, false, false, 0);
            main.pack_end (spin, false, false, 0);
        }
    }
}
