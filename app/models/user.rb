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

  has_many :participants, dependent: :destroy

  has_many :messages, dependent: :destroy

  validates :login, presence: true, uniqueness: true

  mount_uploader :avatar, AvatarUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :omniauthable, omniauth_providers: [:google_oauth2]

  scope :all_except, ->(user) { where.not(id: user) }

  class << self
    def from_omniauth(auth)
      user = find_by(provider: auth.provider, uid: auth.uid) || find_by(email: auth.info.email)

      if user
        user.provider = auth.provider if user.provider.blank?
        user.uid = auth.uid if user.uid.blank?
      else
        user = new
        user_params(user, auth)
      end

      user.skip_confirmation! if user.respond_to?(:confirmed?) && !user.confirmed?
      user.save! if user.changed?
      user
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
      SearchService.new(self).search_user(search)
    end
  end
end
