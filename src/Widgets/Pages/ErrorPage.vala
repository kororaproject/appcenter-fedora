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

namespace AppCenter.Pages {
    public enum ErrorType {
        NO_MATCH_FOUND = 0,
        COULD_NOT_GET_LOCK;
    }
    
    public class ErrorPage : Granite.Widgets.EmbeddedAlert {
        
        private ErrorType? error_type = null;
        
        public ErrorPage () {
        }
        
        // Error string is used just to make errors "better"
        public void set_error_type (ErrorType error, string? error_string = null) {
            this.error_type = error;
            
            if (error_type == ErrorType.NO_MATCH_FOUND) {
                set_alert (_("No match was found for") + " \"" + error_string + "\"",
                            _("Try to change searching matches"));
            }
            
            else if (error_type == ErrorType.COULD_NOT_GET_LOCK) {
                set_alert (_("Could not get lock on applications database"),
                            _("Maybe another application is holding it down"),
                            null, true, Gtk.MessageType.ERROR);
            }
            
        }
        
    }
}
