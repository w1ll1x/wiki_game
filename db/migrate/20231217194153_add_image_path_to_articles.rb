class AddImagePathToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :image_path, :string
  end
end
