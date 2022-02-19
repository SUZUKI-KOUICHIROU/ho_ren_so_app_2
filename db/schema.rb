# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_04_100410) do

  create_table "answers", force: :cascade do |t|
    t.string "question_type"
    t.integer "question_id"
    t.string "value"
    t.text "array_value"
    t.integer "report_id"
    t.index ["report_id"], name: "index_answers_on_report_id"
  end

  create_table "check_box_contents", force: :cascade do |t|
    t.string "check_box_value", default: "", null: false
    t.integer "check_box_id"
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_box_id"], name: "index_check_box_contents_on_check_box_id"
    t.index ["report_id"], name: "index_check_box_contents_on_report_id"
  end

  create_table "check_box_option_strings", force: :cascade do |t|
    t.string "option_string", default: "", null: false
    t.integer "check_box_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_box_id"], name: "index_check_box_option_strings_on_check_box_id"
  end

  create_table "check_boxes", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "check_box", null: false
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_check_boxes_on_question_id"
  end

  create_table "counseling_confirmers", force: :cascade do |t|
    t.integer "counseling_confirmer_id", null: false
    t.text "counseling_reply_detail"
    t.boolean "counseling_reply_flag", default: false, null: false
    t.boolean "counseling_confirmation_flag", default: false, null: false
    t.integer "counseling_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["counseling_id"], name: "index_counseling_confirmers_on_counseling_id"
  end

  create_table "counselings", force: :cascade do |t|
    t.text "counseling_detail", default: "", null: false
    t.date "counseling_reply_deadline"
    t.integer "project_id"
    t.integer "sender_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_counselings_on_project_id"
  end

  create_table "date_field_contents", force: :cascade do |t|
    t.date "date_field_value", null: false
    t.integer "date_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_field_id"], name: "index_date_field_contents_on_date_field_id"
  end

  create_table "date_fields", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "date_field", null: false
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_date_fields_on_question_id"
  end

  create_table "joins", force: :cascade do |t|
    t.string "token"
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_confirmers", force: :cascade do |t|
    t.integer "message_confirmer_id", null: false
    t.boolean "message_confirmation_flag", default: false, null: false
    t.integer "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_confirmers_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "message_detail", default: "", null: false
    t.integer "project_id"
    t.integer "sender_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_messages_on_project_id"
  end

  create_table "pdcas", force: :cascade do |t|
    t.text "pdca_plan", default: "", null: false
    t.text "pdca_do", default: "", null: false
    t.text "pdca_check", default: "", null: false
    t.text "pdca_action", default: "", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pdcas_on_user_id"
  end

  create_table "project_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id"], name: "index_project_users_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "project_name", default: "", null: false
    t.integer "project_leader_id", null: false
    t.integer "project_report_frequency", default: 1, null: false
    t.date "project_next_report_date", null: false
    t.boolean "project_reported_flag", default: false, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer "position"
    t.string "form_table_type", default: "", null: false
    t.integer "project_id"
    t.boolean "using_flag", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_questions_on_project_id"
  end

  create_table "radio_button_contents", force: :cascade do |t|
    t.string "radio_button_value", default: "", null: false
    t.integer "radio_button_id"
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["radio_button_id"], name: "index_radio_button_contents_on_radio_button_id"
    t.index ["report_id"], name: "index_radio_button_contents_on_report_id"
  end

  create_table "radio_button_option_strings", force: :cascade do |t|
    t.string "option_string", default: "", null: false
    t.integer "radio_button_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["radio_button_id"], name: "index_radio_button_option_strings_on_radio_button_id"
  end

  create_table "radio_buttons", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "radio_button", null: false
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_radio_buttons_on_question_id"
  end

  create_table "report_confirmers", force: :cascade do |t|
    t.integer "report_confirmer_id", null: false
    t.boolean "report_confirmation_flag", default: false, null: false
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_report_confirmers_on_report_id"
  end

  create_table "report_statuses", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.boolean "has_submitted", default: false
    t.boolean "has_reminded", default: false
    t.date "deadline"
    t.boolean "is_newest", default: true
    t.index ["project_id"], name: "index_report_statuses_on_project_id"
    t.index ["user_id"], name: "index_report_statuses_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.boolean "remanded"
    t.string "remanded_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_reports_on_project_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "select_contents", force: :cascade do |t|
    t.string "select_value", default: "", null: false
    t.integer "select_id"
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_select_contents_on_report_id"
    t.index ["select_id"], name: "index_select_contents_on_select_id"
  end

  create_table "select_option_strings", force: :cascade do |t|
    t.string "option_string", default: "", null: false
    t.integer "select_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["select_id"], name: "index_select_option_strings_on_select_id"
  end

  create_table "selects", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "select", null: false
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_selects_on_question_id"
  end

  create_table "text_area_contents", force: :cascade do |t|
    t.string "text_area_value", default: "", null: false
    t.integer "text_area_id"
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_text_area_contents_on_report_id"
    t.index ["text_area_id"], name: "index_text_area_contents_on_text_area_id"
  end

  create_table "text_areas", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "text_area", null: false
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_text_areas_on_question_id"
  end

  create_table "text_field_contents", force: :cascade do |t|
    t.string "text_field_value", default: "", null: false
    t.integer "text_field_id"
    t.integer "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_text_field_contents_on_report_id"
    t.index ["text_field_id"], name: "index_text_field_contents_on_text_field_id"
  end

  create_table "text_fields", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "text_field", null: false
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_text_fields_on_question_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_name", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.string "invite_digest"
    t.integer "invited_by"
    t.datetime "invite_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
