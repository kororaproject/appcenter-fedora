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
using PackageKit;
using AppCenter.Widgets;
using AppCenter.Utils;

namespace AppCenter.Pages {
    public class AppsInfo : BlankBox {
        public signal void action_response (AppStore.ActionType type, string id);
        public signal void load_info_started ();
        public signal void load_info_finished ();
        
        private Separator separator;
        public RoundBox reviews_box;
        private Box details_box;
        private Spinner load_spinner;
        private Image image;
        private Label pkg_name;
        private Label short_description;
        private Box description_box;
        private Label description;
        private ScreenshotWidget screenshot;
        private Label id;
        private Label version;
        private Label size;
        private Label license;
        private Label url;
        private ActionButton action_button;
        private string pkg_id;
        public AppStore.App app;
        private AppStore.ActionType action_type;
        
        public AppsInfo () {
            base (Orientation.VERTICAL, 0, 5);
            
            // Summary Box (icon, name/short_description and install button)
            Box summary_box = new Box(Orientation.HORIZONTAL, 5);
            summary_box.margin_top = 5;
            summary_box.margin_left = 5;
            summary_box.margin_right = 5;
            Box label_box = new Box (Orientation.VERTICAL, 0);
            label_box.valign = Align.CENTER;
            image = new Image.from_stock(Stock.INFO, IconSize.DIALOG);
            image.set_size_request (48, 48);
            summary_box.pack_start(image, false, false, 0);
            
            pkg_name = new Label (_("Application name"));
            pkg_name.ellipsize = Pango.EllipsizeMode.END;
            pkg_name.halign = Align.START;
            
            version = new Label ("");
            version.halign = Align.START;
            
            Box title_box = new Box (Orientation.HORIZONTAL, 0);
            title_box.pack_start (pkg_name, false, false, 0);
            title_box.pack_start (version, false, false, 5);
            
            short_description = new Label(_("Application description"));
            /*short_description.wrap = true;
            short_description.wrap_mode = Pango.WrapMode.WORD;*/
            short_description.ellipsize = Pango.EllipsizeMode.END;
            short_description.halign = Align.START;
            short_description.use_markup = true;

            label_box.pack_start (title_box, false, false, 0);
            label_box.pack_start (short_description, false, false, 0);
            label_box.valign = Align.START;
            label_box.halign = Align.START;
            
            summary_box.pack_start (label_box, true, true, 0);
            
            // Status box
            Box status_box = new Box (Orientation.VERTICAL, 1);
            
            action_button = new ActionButton ();
            action_button.clicked.connect (emit_action);
            
            status_box.pack_start (action_button, false, false, 0);
            
            summary_box.pack_start (status_box, false, false, 0);
            
            // Description
            description_box = new Gtk.Box (Orientation.HORIZONTAL, 0);
            
            // Textual description
            description = new Label(_("Package description"));
            description.use_markup = true;
            description.margin = 5;
            description.selectable = true;
            description.wrap_mode = Pango.WrapMode.WORD_CHAR;
            description.wrap = true;
            description.valign = Align.START;
            description.halign = Align.START;
            description.vexpand = false;
            
            ScrolledWindow description_scroll = new ScrolledWindow (null, null);
            description_scroll.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            description_scroll.add_with_viewport (description);
            ((Viewport)description_scroll.get_child()).set_shadow_type (ShadowType.NONE);
            
            // Screenshot
            screenshot = new ScreenshotWidget ();
            
            description_box.pack_start (description_scroll, true, true, 0);
            description_box.pack_start (screenshot, true, true, 0);
            
            // Details (version and size)
            details_box = new Box(Orientation.HORIZONTAL, 5);
            details_box.border_width = 5;
            details_box.halign = Align.CENTER;
            details_box.valign = Align.CENTER;
            Box details1 = new Box(Orientation.VERTICAL, 0);
            Box details2 = new Box(Orientation.VERTICAL, 0);
            size = new Label("");
            size.halign = Align.START;
            id = new Label("");
            id.halign = Align.START;
            license = new Label("");
            license.halign = Align.START;
            url = new Label ("");
            url.use_markup = true;
            url.halign = Align.START;
            details2.pack_start(id, false, false, 0);
            details2.pack_start(size, false, false, 0);
            details2.pack_start(license, false, false, 0);
            details2.pack_start(url, false, false, 0);
            
            Label tmp;
            string[] strings = { _("Id"), _("Version"), _("Size"), _("License"), _("Homepage") };
            foreach (string s in strings) {
                tmp = new Label("<b>%s</b>".printf (s));
                tmp.use_markup = true;
                tmp.halign = Align.END;
                details1.pack_start (tmp, false, false, 0);
            }
            
            details_box.pack_start (details1, false, false, 0);
            details_box.pack_start (details2, false, false, 0);
            
            // Separator
            var sep = new Gtk.Separator (Orientation.HORIZONTAL);
            sep.margin_right = 5;
            sep.margin_left = 5;
            
            // Adding widgets
            pack_start (summary_box, false, false, 0);
            pack_start (sep, true, true, 0);
            pack_start (description_box, true, true, 0);
            
            load_spinner = new Spinner();
            load_spinner.set_size_request(32, 32);
            
            pack_start(load_spinner, true, false, 0);
            
        }
        
        public void set_action (AppStore.ActionType type) {
            action_type = type;
            action_button.set_action_type (type);
        }
        
        public void set_status (Info data) {
            switch (data) {
                case Info.INSTALLED:
                    set_action (AppStore.ActionType.REMOVE);
                    break;
                default:
                    set_action (AppStore.ActionType.INSTALL);
                    break;
            }
        }
        
        public void set_details (AppStore.App app) {
            load_info_started ();
            
            this.app = app;
            
            var pkg = app.package;
            // Update some infos when the package status changes
            apps_manager.loading_finished.connect ((type) => {

                if (type == AppStore.LoadingType.INSTALL)
                    set_status (Info.INSTALLED);
                else if (type == AppStore.LoadingType.REMOVE)
                    set_action (AppStore.ActionType.INSTALL);
            });
            
            pkg_id = pkg.get_id ();        
            set_status ((Info)pkg.info);
            
            // Set infos
            set_name (app.name);
            set_summary (app.summary);
            set_description (app.description);
            set_icon (app.icon);
            set_id (pkg.get_name());
            set_version (pkg.get_version ());
            set_size (app.size);
            set_license (app.license);
            set_url (app.url);
            
            // Set screenshot
            screenshot.start_spinner ();
            ScreenshotFactory.get_screenshot_pixbuf_from_package_name.begin (app.id, (obj, res) => {
                var pix = ScreenshotFactory.get_screenshot_pixbuf_from_package_name.end (res);
                screenshot.set_pixbuf (pix);
                screenshot.stop_spinner ();
            });
            
            load_info_finished ();

            this.show_children ();
            load_spinner.set_visible (false);
            load_spinner.stop();
            //reviews_box.set_visible (false);
            
            // Update app history
            last_app = app;
        }
        
        public void emit_action (Button button) {
            action_response (action_type, pkg_id);
        }
        
        public void start_load () {
            this.hide_children();
            load_spinner.set_visible(true);
            load_spinner.start();
        }
        
        public void pack_separator () {
            separator = new Separator(Orientation.HORIZONTAL);
            pack_start(separator, false, false, 0);
        }
        
        public void set_name (string name) {
            this.pkg_name.label = "%s".printf (name);
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H1, this.pkg_name);
        }
        
        public void set_summary (string summary) {
            this.short_description.label = "%s".printf (summary);
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H2, this.short_description);
        }
       
        public void set_description (string description) {
            this.description.set_markup (description);
        } 
        
        public void set_icon (string icon) {
            var pixbuf = get_pixbuf_from_icon_name (icon);
            if (pixbuf != null) {
                image.set_from_pixbuf (pixbuf);
            }
            else {
                image.set_from_icon_name ("applications-other", IconSize.DIALOG);
                image.pixel_size = 128;
            }
        }
        
        public void set_icon_from_path (string path) {
            var pixbuf = get_pixbuf_from_path (path);
            if (pixbuf != null) {
                image.set_from_pixbuf (pixbuf);
            }
            else {
                image.set_from_icon_name ("applications-other", IconSize.DIALOG);
                image.pixel_size = 128;
            }
        }
        
        public void set_id (string id) {
            this.id.label = id;
        }
        
        public void set_version (string version) {
            this.version.label = "%s".printf (nicer_pkg_version (version));
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H2, this.version);
        }
        
        public void set_size (int size) {
            this.size.label = Utils.size_to_str ((int) size);
        }
        
        public void set_license (string license) {
            this.license.label = license;
        }
        
        public void set_url (string url) {
            if (url != "") {
                this.url.label = "<a href=\"%s\">%s</a>".printf (url, _("Website"));
            } else {
                this.url.label = _("unknown");
            }
        }
        
    }
}
