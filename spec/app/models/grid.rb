class Grid
  include Mongoid::Document
  include Mongoid::Contextual::Aggregable::Mongo

  field :bn, as: :business_name, type: String
  field :d, as: :date, type: String
  field :ss, as: :subscription_status, type: String
  field :msf, as: :monthly_subscription_fee, type: Float
  field :esc, as: :email_subscriber_counts, type: Integer
  field :fc, as: :facebook_connected, type: Boolean
  field :is, as: :implementation_status, type: Integer
  field :ar, as: :alltime_revenue, type: Float
  field :cc, as: :campaigns_count, type: Integer
  field :ar, as: :alltime_revenue, type: Float
  field :alc, as: :alltime_locbox_commission, type: Float
  field :als, as: :alltime_locbox_subscription, type: Float
  field :llra, as: :lto_last_ran_at, type: Time
  field :glra, as: :gco_last_ran_at, type: Time
  field :bca, as: :bday_collector_active, type: Boolean
  field :on, as: :owner_name, type: String
  field :oe, as: :owner_email, type: String
  field :oc, as: :owner_cellphone, type: String
  field :ll, as: :last_login, type: Time
  field :amn, as: :acct_manager_name, type: String

end