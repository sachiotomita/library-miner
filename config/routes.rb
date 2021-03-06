Rails.application.routes.draw do
  root 'home#index'

  resources :homes, only: [:index]
  get 'miner', to: 'home#index'

  namespace :api, defaults: { format: :json } do
    resources :operational_status, only: [] do
      collection do
        get 'projects_crawl_status'
        get 'projects_analyze_status'
        get 'crawl_inprogress'
        get 'job_status'
      end
    end

    resources :input_projects, only: [:show] do
      collection do
        get 'crawl_errors'
        get 'analyze_errors'
      end
    end

    resources :management_jobs, only: [:index] do
      collection do
        get 'job_search_lists'
      end
    end

    resources :project_export, only: [:index] do
      collection do
        get 'export_ready'
        get 'export_end'
      end
    end

  end
end
