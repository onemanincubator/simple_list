class InitSimpleListGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => 'init_simple_list'
    end 
  end
  
  def file_name
    "init_simple_list"
  end
end
