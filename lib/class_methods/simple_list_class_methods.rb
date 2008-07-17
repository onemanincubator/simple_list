module SimpleList
  
  class << self
    
    def all_simple_list_lists
      (ActiveRecord::Base.connection.tables - ['schema_info','sessions']).map {|table| 
            table.classify.constantize.simple_list_lists if
            table.classify.constantize.respond_to?('simple_list_lists')
            }.flatten.compact.uniq.sort
    end
        
    def all_simple_list_multi_lists
      (ActiveRecord::Base.connection.tables - ['schema_info','sessions']).map {|table| 
            table.classify.constantize.simple_list_multi_lists if
            table.classify.constantize.respond_to?('simple_list_multi_lists')
            }.flatten.compact.uniq.sort
    end
    
  end
  
end
