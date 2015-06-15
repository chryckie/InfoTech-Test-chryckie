class Image < ActiveRecord::Base
	scope :sorted, lambda { order("images.id ASC") }
	scope :newest_first, lambda { order("images.created_at DESC") }
end
