class CreateFilms < ActiveRecord::Migration[5.2]
  def change
    create_table :films do |t|
      t.string :title
      t.integer :episode_id
      t.text :opening_crawl
      t.string :director
      t.string :producer
      t.text :characters
      t.datetime :release_date
      t.string :url
      t.datetime :created
      t.datetime :edited
      t.string :etag

      t.timestamps
    end
  end
end
