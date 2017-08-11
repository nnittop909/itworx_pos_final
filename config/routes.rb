Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users", sessions: "users/sessions" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "store/index"
  get 'products/index'


  root :to => "store#index", :constraints => lambda { |request| request.env['warden'].user.nil? }, as: :unauthenticated_root
  root :to => 'store#index', :constraints => lambda { |request| request.env['warden'].user.role == 'proprietor' if request.env['warden'].user }, as: :admin_root
  root :to => 'products#index', :constraints => lambda { |request| request.env['warden'].user.role == 'stock_custodian' if request.env['warden'].user }, as: :stock_custodian_root
  root :to => 'accounting/accounts#index', :constraints => lambda { |request| request.env['warden'].user.role == 'bookkeeper' if request.env['warden'].user }, as: :bookkeeper_root

  resources :products do
    get :autocomplete_product_name_and_description, on: :collection
    match "/scope_to_category" => "products#scope_to_category", as: :scope_to_category, via: [:get], on: :collection
    resources :stocks, only: [:new, :create], module: :products
    match "/cash_sales" => "products#cash_sales", as: :cash_sales, via: [:get], on: :member
    match "/credit_sales" => "products#credit_sales", as: :credit_sales, via: [:get], on: :member
    match "/stock_histories" => "products#stock_histories", as: :stock_histories, via: [:get], on: :member
    match "/reports" => "products#reports", as: :reports, via: [:get], on: :member
    match "/scope_to_date_cash_sales" => "products#scope_to_date_cash_sales",  via: [:get], on: :member
    match "/scope_to_date_credit_sales" => "products#scope_to_date_credit_sales",  via: [:get], on: :member
    match "/scope_to_date_sales" => "products#scope_to_date_sales",  via: [:get], on: :member
    collection { post :import}
  end

  resources :caterings
  resources :catering_line_items
  resources :catering_carts

  resources :departments do
    resources :payments, only: [:new, :create], module: :departments
    match "/info" => "departments#info", as: :info, via: [:get], on: :member
    match "/purchases" => "departments#purchases", as: :purchases, via: [:get], on: :member
    match "/account_details" => "departments#account_details", as: :account_details, via: [:get], on: :member

    resources :line_items, only: [:index], module: :departments do
      match "/scope_to_date" => "line_items#scope_to_date",  via: [:get], on: :collection, module: :departments
    end
  end

  resources :line_items do
    resources :credit_payments, only: [:new, :create], module: :accounting
    match "/return_line_item" => "line_items#return_line_item", as: :return_line_item, via: [:get, :post]
  end

  resources :carts
  resources :orders do
    resources :sales_returns, only: [:destroy], module: :orders
    match "/guest" => "orders#guest",  via: [:post], on: :member
    match "/print" => "orders#print",  via: [:get], on: :member
    match "/print_invoice" => "orders#print_invoice",  via: [:get], on: :member
    match "/print_official_receipt" => "orders#print_official_receipt",  via: [:get], on: :member
    match "/scope_to_date" => "orders#scope_to_date",  via: [:get], on: :collection
    match "/scope_to_date_summary" => "orders#scope_to_date_summary",  via: [:get], on: :collection
    match "/retail" => "orders#retail", as: :retail, via: [:get], on: :collection
    match "/wholesale" => "orders#wholesale", as: :wholesale, via: [:get], on: :collection
    match "/sales_returns" => "orders#sales_returns", as: :sales_returns, via: [:get], on: :collection
    match "/return_order" => "orders#return_order", as: :return_order, via: [:get, :post]
  end

  resources :members do
    get :autocomplete_member_full_name, on: :collection
    resources :payments, only: [:new, :create], module: :members
    resources :interests, only: [:new, :create], module: :members

    match "/info" => "members#info", as: :info, via: [:get], on: :member
    match "/purchases" => "members#purchases", as: :purchases, via: [:get], on: :member
    match "/account_details" => "members#account_details", as: :account_details, via: [:get], on: :member

    resources :line_items, only: [:index], module: :members do
      match "/scope_to_date" => "line_items#scope_to_date",  via: [:get], on: :collection, module: :members
    end
    collection { post :import}
  end
  
  resources :payables, only: [:index]
  resources :suppliers, :except => [:destroy] do
    get :autocomplete_supplier_owner, on: :collection
    resources :payments, only: [:new, :create], module: :suppliers
    match "/cash_stocks" => "suppliers#cash_stocks", as: :cash_stocks, via: [:get], on: :member
    match "/credit_stocks" => "suppliers#credit_stocks", as: :credit_stocks, via: [:get], on: :member
    match "/credit_payments" => "suppliers#credit_payments", as: :credit_payments, via: [:get], on: :member

  end
  resources :reports, only: [:index]
  resources :settings, only: [:index]
  resources :regular_interest_rates, only: [:new, :create , :edit, :update]
  resources :irregular_interest_rates, only: [:new, :create , :edit, :update]
  resources :credits, only: [:index]
  namespace :accounts_receivables do
    resources :interests, only:[:create]
  end
  resources :available_products, only: [:index]

  resources :low_stock_products, only: [:index]
  resources :out_of_stock_products, only: [:index]
  resources :expired_products, only: [:index]


  resources :refunds, only: [:index, :new, :create]
  resources :taxes, only: [:new, :create]
  resources :categories
  resources :wholesales
  resources :stocks, only: [:index, :show, :new, :create, :destroy] do
    get :autocomplete_stock_name, on: :collection
    match "/merge" => "stocks#merge",  via: [:post], on: :member
    resources :merge_stocks, only: [:new, :create], module: :stocks
    match "/scope_to_date" => "stocks#scope_to_date",  via: [:get], on: :collection
    resources :refunds, only: [:new, :create], module: :stocks
    resources :stock_transfers, only: [:new, :create], module: :stocks
    match "/expired" => "stocks#expired", via: [:get], on: :collection
    match "/out_of_stock" => "stocks#out_of_stock", via: [:get], on: :collection
    match "/returned" => "stocks#returned", via: [:get], on: :collection
    match "/forwarded" => "stocks#forwarded", via: [:get], on: :collection
    match "/discontinued" => "stocks#discontinued", via: [:get], on: :collection
    match "/discontinue" => "stocks#discontinue", as: :discontinue, via: [:get, :post]
    match "/continue" => "stocks#continue", as: :continue, via: [:get, :post]
  end
  namespace :wholesales do
    resources :line_items
    resources :orders
  end
  resources :businesses
  resources :info, only: [:index]
  resources :users, only: [:show, :edit, :update] do 
    match "/info" => "users#info", as: :info, via: [:get], on: :member
    match "/activities" => "users#activities", as: :activities, via: [:get], on: :member
  end
  resources :employees, only: [:new, :create]
  resources :accounting, only: [:index] do
    get :autocomplete_account_name, on: :collection
  end
  namespace :accounting do
    resources :balance_sheet, only:[:index]
    resources :income_statement, only:[:index]
    resources :dashboard, only: [:index]
    resources :reports, only:[:index]
    resources :accounts do
      get :autocomplete_accounting_account_name, on: :collection
      match "/activate" => "accounts#activate", via: [:post], on: :member
      match "/deactivate" => "accounts#deactivate", via: [:post], on: :member
    end
    resources :assets, controller: 'accounts', type: 'Accounting::Asset'
    resources :liabilities, controller: 'accounts', type: 'Accounting::Liability'
    resources :equities, controller: 'accounts', type: 'Accounting::Equity'
    resources :revenues, controller: 'accounts', type: 'Accounting::Revenue'
    resources :expenses, controller: 'accounts', type: 'Accounting::Expense'
    resources :member_entries, only: [:new, :create]
    resources :employee_entries, only: [:new, :create]
    resources :supplier_entries, only: [:new, :create]
    resources :sales_entries, only: [:new, :create]

    resources :entries do
      get :autocomplete_entry_description, on: :collection
      match "/scope_to_date" => "entries#scope_to_date", as: :scope_to_date, via: [:get], on: :collection
    end
  end

  namespace :owner do
    resources :dashboard, only: [:index]
  end
  resources :warranties, only: [:new, :create]
  resources :birs
  resources :retail_pricelists, only: [:index]
  resources :wholesale_pricelists, only: [:index]
  resources :sales_returns, only: [:new, :destroy]
  resources :programs
end
