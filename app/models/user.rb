class User < ApplicationRecord
  has_many :sent_contacts, class_name: "Contact", foreign_key: "sender_id"
  has_many :received_contacts, class_name: "Contact", foreign_key: "receiver_id"
  has_many :notifications

  mount_uploader :avatar, AvatarUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: [ :google_oauth2 ]

  class << self
    def from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.login = auth.info.email.split('@').first
      end
    end
  end

  class << self
    def search(search)
      SearchService.new(self).search(search)
    end
  end
end
