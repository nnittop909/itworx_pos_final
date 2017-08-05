class Business < ApplicationRecord
  has_attached_file :logo,
  styles: { large: "120x120>",
            medium: "70x70>",
            thumb: "40x40>",
            small: "30x30>",
            x_small: "20x20>"},
  default_url: ":style/logo_default.png",
  :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
  :url => "/system/:attachment/:id/:style/:filename"

    validates_attachment :logo, content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }
end
