class SimpleListContent < ActiveRecord::Base
  belongs_to :content, :polymorphic => true
  belongs_to :simple_list_item
  belongs_to :simple_list_list
end
