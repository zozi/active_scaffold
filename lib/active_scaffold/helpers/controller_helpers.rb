module ActiveScaffold
  module Helpers
    module ControllerHelpers
      def self.included(controller)
        controller.class_eval { helper_method :params_for, :main_path_to_return }
      end
      
      include ActiveScaffold::Helpers::IdHelpers
      
      def params_for(options = {})
        # :adapter and :position are one-use rendering arguments. they should not propagate.
        # :sort, :sort_direction, and :page are arguments that stored in the session. they need not propagate.
        # and wow. no we don't want to propagate :record.
        # :commit is a special rails variable for form buttons
        blacklist = [:adapter, :position, :sort, :sort_direction, :page, :record, :commit, :_method, :authenticity_token, :format]
        unless @params_for
          @params_for = params.except *blacklist
          @params_for[:controller] = '/' + @params_for[:controller] unless @params_for[:controller].first(1) == '/' # for namespaced controllers
          @params_for.delete(:id) if @params_for[:id].nil?
        end
        @params_for.merge(options)
      end

      # Parameters to generate url to the main page (override if the ActiveScaffold is used as a component on another controllers page)
      def main_path_to_return
        parameters = params_for(:action => :index, :id => nil)
        parameters[:controller] = parent_controller if parent_controller
        parameters[:eid] = params[:parent_controller] if params[:parent_controller]
        active_scaffold_constraints.each do |key, value|
          association = active_scaffold_config.model.reflect_on_association(key)
          parameters.delete((association.options[:polymorphic] ? value.class.name : association.class_name).foreign_key)
        end if parent_controller
        parameters
      end
    end
  end
end
