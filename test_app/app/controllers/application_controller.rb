class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def home
  end
  
  def function
    @function = params[:fn]
    @function_data = Bumbleberry::bumbleberry_functions[params[:fn].to_sym]
    raise ActionController::RoutingError.new('Not Found') unless @function_data
  end
  
end
