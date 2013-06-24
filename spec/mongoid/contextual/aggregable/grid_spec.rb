require "spec_helper"

describe Grid do
  let (:r) do
    Random.new
  end

  let(:grid) do
    Grid.last
  end

  before do
    (1..100).each do |index|
      Grid.create(
          business_name: "business_#{index}",
          date: Time.now,
          subscription_status: 'active',
          monthly_subscription_fee: r.rand(300),
          email_subscriber_counts: r.rand(300),
          implementation_status: 1,
          facebook_connected: true,
          alltime_revenue: r.rand(300),
          alltime_locbox_commission: r.rand(300),
          alltime_locbox_subscription: r.rand(300),
          lto_last_ran_at: Time.now,
          gco_last_ran_at: Time.now,
          bday_collector_active: true,
          owner_name: "owner_#{index}",
          owner_email: "email_#{index}@gmail.com",
          owner_cellphone: "cell_#{index}",
          last_login: Time.now,
          acct_manager_name: "MM_#{index}"
      )
    end

  end

  it "should validate grid values" do
    grid.business_name.should be_a_kind_of(String)
    grid.date.should be_a_kind_of(String)
    grid.subscription_status.should be_a_kind_of(String)
    grid.monthly_subscription_fee.should be_a_kind_of(Float)
    grid.email_subscriber_counts.should be_a_kind_of(Integer)
    grid.implementation_status.should be_a_kind_of(Integer)
    grid.alltime_revenue.should be_a_kind_of(Float)
    grid.alltime_locbox_commission.should be_a_kind_of(Float)
    grid.alltime_locbox_subscription.should be_a_kind_of(Float)
    grid.lto_last_ran_at.should be_a_kind_of(Time)
    grid.gco_last_ran_at.should be_a_kind_of(Time)
    grid.bday_collector_active.should be_a(TrueClass)
    grid.owner_name.should be_a_kind_of(String)
    grid.owner_email.should be_a_kind_of(String)
    grid.owner_cellphone.should be_a_kind_of(String)
    grid.last_login.should be_a_kind_of(Time)
    grid.acct_manager_name.should be_a_kind_of(String)
  end
end