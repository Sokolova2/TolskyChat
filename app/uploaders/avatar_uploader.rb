# frozen_string_literal: true

class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
  include CarrierWave::MiniMagick

  def default_url(*_args)
    ActionController::Base.helpers.asset_path('avatar.svg')
  end

  def size_range
    0..(50.megabytes)
  end

  version :thumb do
    process resize_to_fit: [50, 50]
  end

  version :medium do
    process resize_to_fit: [300, 300]
  end
  def extension_allowlist
    %w[jpg jpeg png]
  end
end
