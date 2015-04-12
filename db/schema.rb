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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150411152756) do

  create_table "docker_cvms", force: true do |t|
    t.string   "container_name"
    t.integer  "ispublid"
    t.float    "cpu"
    t.integer  "ram"
    t.string   "open_folder_path"
    t.integer  "storage_required"
    t.string   "container_long_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "docker_users_id"
    t.integer  "docker_images_id"
    t.integer  "docker_hosts_id"
  end

  create_table "docker_hosts", force: true do |t|
    t.string   "hostname"
    t.string   "ip"
    t.string   "username"
    t.string   "password"
    t.float    "cpu"
    t.integer  "ram"
    t.integer  "storage"
    t.string   "host_os"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "docker_images", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "baseimageid"
    t.string   "userid"
    t.integer  "ispublic"
    t.integer  "isbaseimage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "docker_users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password"
    t.time     "lastlogin"
    t.string   "oldpassword"
    t.integer  "isadmin"
    t.integer  "no_of_vm_running"
    t.integer  "max_vm_allowed"
    t.integer  "no_of_vm_hosted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
