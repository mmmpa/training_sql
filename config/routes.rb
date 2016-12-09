Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'students/' => 'students#index', as: :students
  post 'students/' => 'students#create'
  get 'students/:student_id' => 'students#show', as: :student
end
