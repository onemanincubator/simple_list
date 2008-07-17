module SimpleList
  
  module ModelMethods
        
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end

    module ClassMethods 
      
      #################################################################################
      #
      # acts_as_simple_list
      #
      #################################################################################
      
      def acts_as_simple_list(attribute, options={})
                
        return if attribute.blank?
        return unless ActiveRecord::Base.connection.tables.include?(
        	self.name.tableize) # end gracefully if table not created yet
        options.stringify_keys!
        foreign_key = options['foreign_key']
        foreign_key ||= "#{attribute}_id" if 
        	self.column_names.include?("#{attribute.to_s}_id")
        return unless foreign_key
        
        belongs_to attribute.to_sym, :class_name => 'SimpleListItem', 
        	:foreign_key => foreign_key
        
        cattr_accessor :simple_list_attributes_hash
        self.simple_list_attributes_hash ||= {}
        self.simple_list_attributes_hash.merge!(
        	attribute.to_s => {'list' => (options['list'] || attribute)})
        
        unless self.respond_to?('is_it_a_simple_list?')
        	def self.is_it_a_simple_list?(attribute)
        		(attribute = attribute[0..-4]) if /_id\z/ =~ attribute
        		return unless (assoc = self.reflect_on_association(attribute.to_sym))
        		assoc.table_name == 'simple_list_items' rescue return false
        	end
        end
        
        include SimpleList::ModelMethods::InstanceMethods
        
      end
      
      #################################################################################
      #
      # acts_as_multi_simple_list
      #
      #################################################################################
      
      def acts_as_multi_simple_list(multi_list)
      
      	return if multi_list.blank?
      	multi_list = multi_list.to_s
      	
        cattr_accessor :simple_list_multi_lists
				self.simple_list_multi_lists ||= []
        self.simple_list_multi_lists << multi_list
        
        # add/remove simple_list_contents after new record is created or updated
        after_save "set_#{multi_list}"
        
        #
        # {multi_list}
        #
          
        define_method(multi_list) do
          self.send("simple_list_content_for_#{multi_list}").map {|r| r.simple_list_item}
        end
          
        # main save method for generating the appropriate associations          
        define_method("#{multi_list}=") do |new_items|
          return if self.new_record? # can't create associations with new record
            
          # gather new_item_ids
          if new_items.is_a? NilClass # command to delete all old items
            new_item_ids = []
          elsif new_items.is_a? Array # new items gathered via check boxes
            new_item_ids = new_items
          elsif new_items.is_a? String # new items gathered via a string
            list = SimpleListList.find_or_create(multi_list)
            new_item_ids = new_items.strip.split(/[\s,;]+/).uniq.collect {|s| 
              SimpleListItem.find_or_create_by_name_and_simple_list_list_id(s, list.id).id.to_s}
          else # some unrecognized kind of assignment
            return
          end
            
          # gather old_item_ids
          old_slcs = Hash[*self.send("simple_list_content_for_#{multi_list}").map {|h| 
                              [h.simple_list_item_id, h]}.flatten].stringify_keys
          old_item_ids = old_slcs.keys
           
          # destroy habtms for deleted items
          (old_item_ids - new_item_ids).each do |id_to_destroy|
            old_slcs[id_to_destroy].destroy
          end
            
          # create habtms for new items
          list ||= SimpleListList.find_or_create(multi_list)
          (new_item_ids - old_item_ids).each do |id_to_create|
            SimpleListContent.create(
                :content_type   => self.class.name,
                :content_id     => self.id,
                :simple_list_list_id => list.id,
                :simple_list_item_id => id_to_create)
          end
            
        end
          
        #
        # set_{multi_list}
        #
          
        # invoke #{multi_list}= if there has been an assignment
        define_method("set_#{multi_list}") do
          # {multi_list}_list was among the posted params
          if instance_variable_get("@#{multi_list}_list_assigned")
            self.attributes = {"#{multi_list}" => self.send("#{multi_list}_list")}
             
          # {multi_list}_id was among the posted params
          elsif instance_variable_get("@#{multi_list}_id_assigned")
            self.attributes = {"#{multi_list}" => self.send("#{multi_list}_id")}
             
          end
        end
          
        # virtual fields used in forms
        # these are needed because {multi_list} is an attribute of
        # self, but we shouldn't save the {multi_list} associations
        # until self has been successfully validated and saved
        attr_accessor "#{multi_list}_id" # arrays of item ids
        attr_accessor "#{multi_list}_list" # string of item names
        attr_accessor "#{multi_list}_id_assigned"
        attr_accessor "#{multi_list}_list_assigned"
          
        ## attr_accessor variable (e.g. {multi_list}_id) read and write methods
        #   - read sets the variable from the db if nil -- needed for reading self
        #   - write (=) sets the variable from the param -- this assignment is noted 
        #     just in case self is successfully saved
          
        #
        # {multi_list}_id
        #
          
        define_method("#{multi_list}_id") do
          # initialize #{multi_list}_id if self exists
          if instance_variable_get("@#{multi_list}_id").nil? && !self.new_record? &&
            !(list = self.send(multi_list).compact).blank?
            instance_variable_set("@#{multi_list}_id", list.collect {|item| item.id.to_s})
          end
          instance_variable_get("@#{multi_list}_id")
        end
          
        define_method("#{multi_list}_id=") do |array|
          if array.is_a? Array
            instance_variable_set("@#{multi_list}_id", array)
          else
            instance_variable_set("@#{multi_list}_id", [])
          end
          instance_variable_set("@#{multi_list}_id_assigned", true) 
        end
            
        #
        # {multi_list}_list
        #
        
        define_method("#{multi_list}_list") do
          # initialize #{multi_list}_list if self exists
          if instance_variable_get("@#{multi_list}_list").nil? && !self.new_record? &&
               !(list = self.send(multi_list).compact).blank?
            instance_variable_set("@#{multi_list}_list", 
                                  list.collect(&:name).join(' '))
          end
          instance_variable_get("@#{multi_list}_list")
        end
          
        define_method("#{multi_list}_list=") do |string|
          if string.is_a? String
            instance_variable_set("@#{multi_list}_list", string)
          else
            instance_variable_set("@#{multi_list}_list", "")
          end
          instance_variable_set("@#{multi_list}_list_assigned", true) 
        end
          
        ## association (i.e. {multi_list}) read and write methods
         
        #
        # selectables_for_{multi_list}
        #
         
        define_method("simple_list_content_for_#{multi_list}") do
          SimpleListContent.find_all_by_content_type_and_content_id_and_simple_list_list_id(
          	self.class.name, self.id, SimpleListList.find_or_create(multi_list))
        end  
        
        unless self.respond_to?('is_it_a_multi_simple_list?')
        	def self.is_it_a_multi_simple_list?(attribute_name)
          	return false unless self.simple_list_multi_lists
          	attribute_name = attribute_name.to_s
          	list_name = /_id\z/ =~ attribute_name ? attribute_name[0..-4] : 
                      (/_list\z/ =~ attribute_name ? attribute_name[0..-6] : 
                      attribute_name)
          	return self.simple_list_multi_lists.include?(list_name)
        	end
     		end
        
      end
    end

    module InstanceMethods
      
      # returns an array of select-ready choices for the attribute
      def selection_choices_for(attribute_name)
        return unless self.class.respond_to?('simple_list_attributes_hash')
        if /_id\z/ =~ attribute_name # attribute name is a table field
        	return unless (assoc = Crud.get_association(
        															self.class.name, attribute_name))
        	attribute_name = assoc.name.to_s # get the association name
        end
        return unless (attr = self.simple_list_attributes_hash[attribute_name])
        return if (list_name = attr['list']).blank?
        return unless (list = SimpleListList.find_by_name(list_name))
        return if (items = list.simple_list_items).blank?
        items.map {|item| [item.name, item.id]}
      end
      
    end
  end
end
