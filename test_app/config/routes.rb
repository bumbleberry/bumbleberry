Rails.application.routes.draw do
    root 'application#home', :as => :home
    get 'fn/:fn' => 'application#function', :as => :function
end
