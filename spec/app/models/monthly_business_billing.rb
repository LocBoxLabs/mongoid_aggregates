class MonthlyBusinessBilling
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :business_id, type: Integer
  field :real_date, type: Time
  field :date, type: String, default: ->{ real_date.try(:strftime, '%Y-%m') }

  validates_presence_of :business_id

  embeds_one :billings, class_name: 'BusinessBillings'
  embeds_one :subscription, class_name: 'BusinessSubscription'

  accepts_nested_attributes_for :billings, :subscription

  scope :with_subscription_status, ->(status){ where('subscription.status' => status) }
  scope :for_month, ->(date_str){ where('date' => date_str) }
end



class BusinessBillings
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :cc_fee, type: Float
  field :lb_commission, type: Float
  field :gross_revenue, type: Float
  field :net_revenue, type: Float
  field :_id, type: String, default: nil

  embedded_in :monthly_business_billing
end


class BusinessSubscription
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :subscription, type: Float
  field :subscription_id, type: Integer
  field :mrr_contribution, type: Float
  field :setup_fee, type: Float
  field :monthly_fee, type: Float
  field :total, type: Float
  field :other, type: Float
  field :status, type: String
  field :last_status_update, type: Time
  field :created_at, type: Time, default: ->{ Time.now }
  field :_id, type: String, default: nil

  embedded_in :monthly_business_billing
end