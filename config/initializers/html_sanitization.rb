# frozen_string_literal: true

Rails::HTML::WhiteListSanitizer.allowed_tags << 'video'
Rails::HTML::WhiteListSanitizer.allowed_tags << 'source'
Rails::HTML::WhiteListSanitizer.allowed_attributes << 'controls'
