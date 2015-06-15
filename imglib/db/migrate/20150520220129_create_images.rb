class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
	  t.string 'key', :limit => 200, :null => false
      t.string 'caption', :limit => 100, :default=>"Untitled"
	  t.string 'description', :limit => 500
	  t.string 'alt_text', :limit => 100
      t.timestamps null: false
    end
  end
end
