# requirements for mixins
require 'action_controller'
require 'action_view'
require 'active_record'

# mixins
require 'mixins/simple_list_model'
ActiveRecord::Base.class_eval {include SimpleList::ModelMethods}
require 'mixins/simple_list_helper'
ActionView::Base.module_eval {include SimpleList::HelperMethods}
require 'mixins/simple_list_controller'
ActionController::Base.class_eval {include SimpleList::ControllerMethods}

# class methods
require 'class_methods/simple_list_class_methods'

# models
require 'models/simple_list_list'
require 'models/simple_list_item'
require 'models/simple_list_content'

module SimpleList
end
