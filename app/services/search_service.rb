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
end
