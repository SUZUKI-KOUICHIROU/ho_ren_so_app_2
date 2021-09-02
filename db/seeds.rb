# coding: utf-8

User.create!(user_name: 'Admin User',
             email: 'admin@email.com',
             password: 'password',
             password_confirmation: 'password',
             admin: true)

User.create!(user_name: 'Sample User',
             email: 'sample@email.com',
             password: 'password',
             password_confirmation: 'password',
             admin: false)
