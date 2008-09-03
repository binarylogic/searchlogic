require "test/unit"
require "rubygems"
require "ruby-debug"
require "activerecord"
require File.dirname(__FILE__) + '/libs/acts_as_tree'
require File.dirname(__FILE__) + '/libs/rexml_fix'
require File.dirname(__FILE__) + '/../lib/searchgasm'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class Account < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :orders, :through => :users
end

class User < ActiveRecord::Base
  acts_as_tree
  belongs_to :account
  has_many :orders, :dependent => :destroy
end

class Order < ActiveRecord::Base
  belongs_to :user
end

class Test::Unit::TestCase
  def self.fixtures(*fixtures)
    @fixtures ||= []
    @fixtures += [fixtures].flatten
  end
  
  def setup_db
    ActiveRecord::Schema.define(:version => 1) do
      create_table :accounts do |t|
        t.datetime  :created_at    
        t.datetime  :updated_at
        t.string    :name
        t.boolean   :active
      end

      create_table :users do |t|
        t.datetime  :created_at      
        t.datetime  :updated_at
        t.integer   :account_id
        t.integer   :parent_id
        t.string    :first_name
        t.string    :last_name
        t.boolean   :active
        t.text      :bio
      end

      create_table :orders do |t|
        t.datetime  :created_at      
        t.datetime  :updated_at
        t.integer   :user_id
        t.float     :total
        t.text      :description
        t.binary    :receipt
      end
    end
  end
  
  def load_fixtures
    self.class.fixtures.each do |fixture|
      records = YAML.load(File.read(File.dirname(__FILE__) + "/fixtures/#{fixture.to_s}.yml"))
      records.each do |name, attributes|
        record = fixture.to_s.singularize.classify.constantize.new
        attributes.each { |k, v| record.send("#{k}=", v) }
        record.save!
      end
    end
  end
  
  def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end