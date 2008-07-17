module SimpleList
  
  module ControllerMethods
    
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end

    module ClassMethods 
      def runs_like_simple_list(options={})
        
        include SimpleList::ControllerMethods::InstanceMethods

      end
    end

    module InstanceMethods

      def manage_simple_list_list
        list = SimpleListList.find_or_create(params[:list])
        @list_name = list.name 
        wrapper = "#{@list_name}Wrapper"
        case params[:ajax_action]
        when 'close'
          render :update do |page| (page.replace_html wrapper, nil) end and return
        when 'add'
          list.find_or_create_item(params[:simple_list_item][:name].strip)
        when 'move_up'
          list.simple_list_items.find(params[:item_id]).move_higher
        when 'move_down'
          list.simple_list_items.find(params[:item_id]).move_lower
        when 'delete'
          list.simple_list_items.find(params[:item_id]).destroy
        end
        @simple_list_items = list.simple_list_items(true)
        render :update do |page|
          page.replace_html wrapper, simple_list_items_tag
        end
      end
      
    end
  end
end
