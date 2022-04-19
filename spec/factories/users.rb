FactoryBot.define do
  factory :user do
    id { 1 }
    user_name { 'Admin User' }
    email { 'admin@email.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
    has_editted { true }
  end
end
