Rails.application.routes.draw do
  
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  Blacklight::Marc.add_routes(self)
  root to: "catalog#index"
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # hack to get advanced search to at least start

  # https://groups.google.com/d/msg/blacklight-development/Lps2C8DYj0c/q2pvEtmyAwAJ
  get 'advanced' => 'advanced#index', as: 'advanced_search'
  match 'advanced/range_limit', :to => 'advanced#range_limit', :as => 'catalog_range_limit', :via => [:get, :post]

  # https://github.com/projectblacklight/blacklight_range_limit/issues/58
  #get 'advanced' => 'advanced#index'
  #get 'advanced/range_limit' => 'advanced#range_limit'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
