class SimpleListList < ActiveRecord::Base
  has_many :simple_list_items, :order => :position, :dependent => :destroy
  has_many :simple_list_contents, :dependent => :destroy
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  def self.find_or_create(list_name)
    self.find_or_create_by_name(list_name)
  end
  
  def find_or_create_item(item_name)
    return unless item_name.is_a? String
    SimpleListItem.find_or_create_by_name_and_simple_list_list_id(
    		item_name, self.id)
  end
  
  def insert_item(simple_list_item)
    return unless simple_list_item.is_a? SimpleListItem
    simple_list_item.update_attributes(
        :position =>          self.simple_list_items[-1].position + 1,
        :simple_list_list_id => self.id)
  end
  
  def name_with_url
    self.url.blank? ? self.name : "<a href=\"#{self.url}\" target=\"_blank\">#{self.name}</a>"
  end
  
end
