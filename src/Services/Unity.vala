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
    public class UnityProgressBar : GLib.Object {
        
        private int jobs = 0;
        private Unity.LauncherEntry launcher_entry;
        
        public UnityProgressBar () {
            launcher_entry = Unity.LauncherEntry.get_for_desktop_id (Constants.LAUNCHER);
        }
        
        public void set_progress (double percentage) {
            // If it is not 100 % show it
            launcher_entry.progress = (percentage/jobs);
            launcher_entry.progress_visible = true;
        }
        
        // Add new red badge to show the number of pending works
        public void append_job () {
            jobs++;
            
            launcher_entry.count = jobs;
            launcher_entry.count_visible = true;
        }
        
        public void clear () {
            jobs = 0;
            launcher_entry.count = jobs;
            launcher_entry.count_visible = false;
            launcher_entry.progress_visible = false;
        }
    }
}
