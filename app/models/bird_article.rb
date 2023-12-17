# frozen_string_literal: true

class BirdArticle < Article
  has_one_attached :mp3_file
end
