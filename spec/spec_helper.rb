require(File.dirname(__FILE__) + '/../lib/searchlogic.rb')
require 'database_cleaner'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 3) do
  create_table :users do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.integer :company_id
    t.string :username
    t.string :name
    t.integer :age
    t.boolean :male
    t.string :some_type_id
    t.datetime :whatever_at
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