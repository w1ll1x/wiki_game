class AddTypeToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :type, :string
  end
end
