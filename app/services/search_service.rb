# frozen_string_literal: true

class SearchService
  def initialize(model)
    @model = model
  end

  def search(search)
    return @model.all if search.blank?

    @model.where('login ILIKE ?', "%#{search}%")
  end
end