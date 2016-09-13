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

ActiveRecord::Schema.define(version: 20160912235011) do

  create_table "absences", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "performanceset_id"
    t.date     "date"
    t.boolean  "planned"
    t.boolean  "sub_found"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["member_id"], name: "index_absences_on_member_id"
    t.index ["performanceset_id"], name: "index_absences_on_performanceset_id"
  end

  create_table "action_logs", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "user_id"
    t.string   "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_action_logs_on_member_id"
    t.index ["user_id"], name: "index_action_logs_on_user_id"
  end

  create_table "ensembles", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "member_instruments", force: :cascade do |t|
    t.integer  "member_id"
    t.string   "instrument"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_notes", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "user_id"
    t.string   "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_member_notes_on_member_id"
    t.index ["user_id"], name: "index_member_notes_on_user_id"
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_1"
    t.string   "phone_1_type"
    t.string   "phone_2"
    t.string   "phone_2_type"
    t.string   "email_1"
    t.string   "email_2"
    t.string   "emergency_name"
    t.string   "emergency_relation"
    t.string   "emergency_phone"
    t.string   "playing_status"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "initial_date"
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "performance_sets", force: :cascade do |t|
    t.integer  "ensemble_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["ensemble_id"], name: "index_performance_sets_on_ensemble_id"
  end

  create_table "set_member", force: :cascade do |t|
    t.integer  "set_id"
    t.integer  "member_id"
    t.string   "set_status"
    t.string   "string"
    t.boolean  "rotating"
    t.boolean  "boolean"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_set_member_on_member_id"
    t.index ["set_id"], name: "index_set_member_on_set_id"
  end

  create_table "set_member_instruments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                    default: "", null: false
    t.string   "encrypted_password",                       default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                          default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "password_changed_at"
    t.string   "unique_session_id",             limit: 20
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.string   "paranoid_verification_code"
    t.integer  "paranoid_verification_attempt",            default: 0
    t.datetime "paranoid_verified_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["expired_at"], name: "index_users_on_expired_at"
    t.index ["last_activity_at"], name: "index_users_on_last_activity_at"
    t.index ["paranoid_verification_code"], name: "index_users_on_paranoid_verification_code"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index [nil], name: "index_users_on_parnaoid_verified_at"
  end

end
