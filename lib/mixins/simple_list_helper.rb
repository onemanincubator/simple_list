module SimpleList
  
  module HelperMethods
    
    def simple_list_list_tag(list_name)
      tag = link_to_remote(list_name, :url => {:action => 'manage_simple_list_list', 
											:list => list_name})
			tag << '<div id='
			tag << list_name
			tag << 'Wrapper>'
			tag << '</div>'
		end
    
    def simple_list_items_tag
      tag = '<hr>['
      tag << link_to_remote("Close", 
                            :url => {:action => 'manage_simple_list_list', 
      								                :list => @list_name, :ajax_action => 'close'})
      tag << ']<br><br>'
      tag << '<div id=items_for_'
      tag << @list_name
      tag << 'Wrapper>'
      tag << '<table cellspacing="5">'
      @simple_list_items.each do |item|
        tag << '<tr>'
          tag << '<td align="center">'
    	      tag << item.name
    	    tag << '</td>'
    	    tag << '<td>'
    	      tag << link_to_remote("up",:url => {:action => 'manage_simple_list_list', 
			                :list => @list_name, :ajax_action => 'move_up', :item_id => item.id})
            tag << "&nbsp;&nbsp;"
    	      tag << link_to_remote("down",:url => {:action => 'manage_simple_list_list', 
			                :list => @list_name, :ajax_action => 'move_down', :item_id => item.id})
            tag << "&nbsp;&nbsp;"
    	      tag << link_to_remote("delete",:url => {:action => 'manage_simple_list_list', 
			                :list => @list_name, :ajax_action => 'delete', :item_id => item.id})
			    tag << '</td>'
        tag << '</tr>'
      end
      tag << '</table>'
      tag << '</div><br>'
      tag << form_remote_tag(:url => {:action => 'manage_simple_list_list', 
                        :list => @list_name, :ajax_action => 'add' })
      	tag << text_field('simple_list_item', 'name', :size => '15')
      	tag << '&nbsp;'
      	tag << submit_tag("Add")
      tag << "</form>"
      tag << '<hr>'
    end  
    
    def multi_select_id_field(object_name, attribute_name, options)
      object = instance_variable_get "@#{object_name}"
      list_name = /_id\z/ =~ attribute_name ? attribute_name[0..-4] : attribute_name
      items = SimpleListList.find_or_create(list_name).simple_list_items
      return "list is empty" if items.blank?
      html_name = options[:name] || "#{object_name}[#{attribute_name}]"
      checked = [object.send(attribute_name)].flatten.compact
      tag = ""
      items.each do |item|
        tag << check_box_tag(object_name, item.id.to_s, checked.include?(item.id.to_s), 
                        :name => "#{html_name}[]")
        tag << "&nbsp;#{item.name}<br>"
      end
      object.errors.invalid?(attribute_name) ?
        content_tag(:div, tag, :class => 'fieldWithErrors') :
        tag
    end
      
    def multi_select_display(content, attribute_name, options = {})
      return unless content.class.is_it_multi_simple_list?(attribute_name)
      list_name = /_id\z/ =~ attribute_name ? attribute_name[0..-4] : 
                  (/_list\z/ =~ attribute_name ? attribute_name[0..-6] : 
                  attribute_name)
      join_str = options.delete(:join) || ' '
      content.send(list_name).map(&:name_with_url).join(join_str)
    end
    
  end

end
