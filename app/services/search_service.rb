# frozen_string_literal: true

class SearchService
  def initialize(model)
    @model = model
  end

  def search_user(search)
    return @model.all if search.blank?

    @model.where('login ILIKE ?', "%#{search}%")
  end

  def search_room(search)
    return @model.all if search.blank?

    @model.where('name ILIKE ?', "%#{search}%")
  end

  def search_contacts_for(user_id, query)
    contacts = Contact.user_contacts(user_id)
    return contacts if query.blank?

    q = "%#{ActiveRecord::Base.sanitize_sql_like(query.strip)}%"

    contacts.where(
      "(contacts.sender_id = :me AND receivers_users.login ILIKE :q) OR
       (contacts.receiver_id = :me AND senders_users.login ILIKE :q)",
      me: user_id, q: q
    )
  end
end
