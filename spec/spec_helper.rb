$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'rspec'
require 'rspec/autorun'

require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'action_view'
require 'timecop'
require 'rspec_tag_matchers'
require 'model_helpers'

require 'validates_timeliness'

ValidatesTimeliness.setup do |c|
  c.extend_classes = [ ActiveModel::Validations, ActiveRecord::Base ]
  c.enable_date_time_select_extension!
end

Time.zone = 'Australia/Melbourne'

LOCALE_PATH = File.expand_path(File.dirname(__FILE__) + '/../lib/validates_timeliness/locale/en.yml')
I18n.load_path.unshift(LOCALE_PATH)

class Person
  include ActiveModel::Validations
  extend  ActiveModel::Translation

  attr_accessor :birth_date, :birth_time, :birth_datetime

  def initialize(attributes = {})
    attributes.each do |key, value|
      send "#{key}=", value
    end
  end
end

ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :employees, :force => true do |t|
    t.string   :first_name
    t.string   :last_name
    t.datetime :birth_date
    t.datetime :birth_time
    t.datetime :birth_datetime
  end
end

class Employee < ActiveRecord::Base
end

Rspec.configure do |c|
  c.mock_with :rspec
  c.include(RspecTagMatchers)
  c.before do
    Person.reset_callbacks(:validate)
    Person._validators.clear
  end
end
