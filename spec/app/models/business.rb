class Business
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :created_at, type: Time, default: ->{ Time.now }
  field :date, type: String
  field :facebook_connected, type: Boolean, default: false
  field :name, type: String
  field :business_id, type: Integer
  field :real_date, type: Time

  validates_presence_of :name, :business_id

  embeds_one :facebook_stats, class_name: 'FacebookStats'
  embeds_one :billings, class_name: 'Billings'
  embeds_one :subscription

  accepts_nested_attributes_for :facebook_stats, :billings

  scope :with_subscription_status, ->(status) { where('subscription.status' => status) }
end

class FacebookStats
  include Mongoid::Document
  embedded_in :business

  field :_id, type: String, default: nil
  field :likes, type: Integer
end

class Billings
  include Mongoid::Document

  field :_id, type: String, default: nil

  embeds_one :daily, class_name: 'BillingsPeriod'
  embeds_one :monthly, class_name: 'BillingsPeriod'
  embeds_one :alltime, class_name: 'BillingsPeriod'
  embedded_in :business

  accepts_nested_attributes_for :daily, :monthly, :alltime
end

class BillingsPeriod
  include Mongoid::Document
  embedded_in :billings

  field :_id, type: String, default: nil
  field :gross_revenue, type: Float
  field :net_revenue, type: Float
end

class Subscription
  include Mongoid::Document
  embedded_in :business

  field :_id, type: String, default: nil
  field :subscription_id, type: Integer
  field :status, type: String
  field :setup_fee, type: Float
  field :setup_fee_charged_at, type: Time
  field :monthly_subscription_fee, type: Float
  field :last_status_update, type: Time
end