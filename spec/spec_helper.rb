

$:.push File.expand_path("../lib", __FILE__) 
require 'database_cleaner'
require 'pry'
require 'active_record'
require 'chronic'
require 'searchlogic'
# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :audits do |t|
    t.string :auditable_type
    t.integer :auditable_id
    t.string :name
  end

  create_table :companies do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.string :name
    t.string :description
    t.integer :users_count, :default => 0
  end

  create_table :user_groups do |t|
    t.string :name
  end

  create_table :user_groups_users, :id => false do |t|
    t.integer :user_group_id, :null => false
    t.integer :user_id, :null => false
  end

  create_table :users do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :company_id
    t.string :username
    t.string :name
    t.integer :count
    t.integer :age
    t.boolean :male
    t.string :email
    t.string :some_type_id
    t.datetime :whatever_at
  end

  create_table :carts do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :user_id
  end

  create_table :orders do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :user_id
    t.date :shipped_on
    t.float :taxes
    t.float :total
    t.string :name
    t.string :title
  end

  create_table :fees do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.string :owner_type
    t.integer :owner_id
    t.float :cost
  end

  create_table :line_items do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :order_id
    t.float :price
  end
end


Spec::Runner.configure do |config|
  config.before(:each) do
    class ::Audit < ActiveRecord::Base
      belongs_to :auditable, :polymorphic => true
    end

    class ::Company < ActiveRecord::Base
      has_many :orders, :through => :users
      has_many :users, :dependent => :destroy
      has_many :audits, :as => :auditable 
    end

    class ::Cart < ActiveRecord::Base
      belongs_to :user
    end

    class ::UserGroup < ActiveRecord::Base
      has_and_belongs_to_many :users
    end

    class ::User < ActiveRecord::Base
      belongs_to :company, :counter_cache => true
      has_many :carts, :dependent => :destroy
      has_many :orders, :dependent => :destroy
      has_many :orders_big, :class_name => 'Order', :conditions => 'total > 100'
      has_many :audits, :as => :auditable
      has_and_belongs_to_many :user_groups

      self.skip_time_zone_conversion_for_attributes = [:whatever_at]
    end

    class ::Order < ActiveRecord::Base
      belongs_to :user
      has_many :line_items, :dependent => :destroy
    end

    class ::Fee < ActiveRecord::Base
      belongs_to :owner, :polymorphic => true
    end

    class ::LineItem < ActiveRecord::Base
      belongs_to :order
    end

    ::Company.destroy_all
    ::User.destroy_all
    ::Order.destroy_all
    ::LineItem.destroy_all
  end
end

Spec::Runner.configure do |config|
    class ::User < ActiveRecord::Base
      belongs_to :company, :counter_cache => true
      has_many :carts, :dependent => :destroy
      has_many :orders, :dependent => :destroy
      has_many :orders_big, :class_name => 'Order', :conditions => 'total > 100'
      has_many :audits, :as => :auditable
      has_and_belongs_to_many :user_groups
      self.skip_time_zone_conversion_for_attributes = [:whatever_at]
    end
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do

    DatabaseCleaner.clean
  end

end
