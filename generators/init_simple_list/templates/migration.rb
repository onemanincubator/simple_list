class InitSimpleList < ActiveRecord::Migration
  def self.up
    create_table :simple_list_lists do |t|
      t.string  :name
      t.text    :description
      t.string  :url
      t.timestamps
    end
    
    create_table :simple_list_items do |t|
      t.string  :name, :url
      t.text    :description
      t.integer :position
      t.references :simple_list_list
      t.timestamps
    end
    
    create_table :simple_list_contents do |t|
      t.references  :content, :polymorphic => true
      t.references  :simple_list_list, :simple_list_item
      t.timestamps
    end
    
    add_index :simple_list_lists, :name
    add_index :simple_list_items, :simple_list_list_id
    add_index :simple_list_items, [:name, :simple_list_list_id],
    					:name => "name_and_list"
    add_index :simple_list_contents, [:content_type, :content_id, :simple_list_list_id],
              :name => "content_and_list"
    add_index :simple_list_contents, [:content_type, :simple_list_item_id],
              :name => "content_type_and_item"
  end
  
  def self.down
    drop_table :simple_list_lists
    drop_table :simple_list_items
    drop_table :simple_list_contents
  end
end
