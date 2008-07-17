class SimpleListItem < ActiveRecord::Base
  belongs_to :simple_list_list
  has_many :simple_list_contents, :dependent => :destroy
  acts_as_list :scope => :simple_list_list_id 
   
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :simple_list_list_id  
  
  def name_with_url
    self.url.blank? ? self.name : "<a href=\"#{self.url}\" target=\"_blank\">#{self.name}</a>"
  end
    
end
