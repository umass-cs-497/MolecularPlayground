# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120821065546) do

  create_table "data_files", :force => true do |t|
    t.string   "filename"
    t.binary   "data",         :limit => 2147483647
    t.integer  "scene_id"
    t.integer  "content_type",                       :default => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  create_table "green_links", :force => true do |t|
    t.string   "title"
    t.integer  "model_id"
    t.integer  "script_id"
    t.integer  "scene_id"
    t.boolean  "active"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "image_id"
  end

  create_table "images", :force => true do |t|
    t.binary   "data",       :limit => 16777215
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "installations", :force => true do |t|
    t.string   "name"
    t.string   "home_page"
    t.integer  "playlist_id"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "time_zone",   :default => "Eastern Time (US & Canada)"
  end

  create_table "installations_users", :id => false, :force => true do |t|
    t.integer "installation_id"
    t.integer "user_id"
  end

  create_table "playlist_items", :force => true do |t|
    t.integer  "playlist_id"
    t.integer  "scene_id"
    t.integer  "position"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "playlists", :force => true do |t|
    t.string   "name"
    t.integer  "installation_id"
    t.boolean  "enabled"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "scenes", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.integer  "status",        :default => 0
    t.string   "first_banner"
    t.string   "second_banner"
    t.text     "description"
    t.string   "web_link"
    t.integer  "startup_id",    :default => 0
    t.integer  "parent_id",     :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "model_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin",                  :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
