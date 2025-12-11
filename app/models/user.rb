# frozen_string_literal: true

class User < ApplicationRecord
  has_many :sent_contacts,
           class_name: 'Contact',
           foreign_key: 'sender_id',
           inverse_of: :sender,
           dependent: :destroy

  has_many :received_contacts,
           class_name: 'Contact',
           foreign_key: 'receiver_id',
           inverse_of: :receiver,
           dependent: :destroy

  has_many :sender_notifications,
           class_name: 'Notification',
           foreign_key: 'sender_id',
           inverse_of: :sender,
           dependent: :destroy

  has_many :receiver_notifications,
           class_name: 'Notification',
           foreign_key: 'receiver_id',
           inverse_of: :receiver,
           dependent: :destroy

  mount_uploader :avatar, AvatarUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: [:google_oauth2]

  scope :all_except, ->(user) { where.not(id: user) }

  class << self
    def from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user_params(user, auth)
      end
    end

    def user_params(user, auth)
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.login = auth.info.email.split('@').first
    end
  end

  class << self
    def search(search)
      SearchService.new(self).search(search)
    end
  end
end
