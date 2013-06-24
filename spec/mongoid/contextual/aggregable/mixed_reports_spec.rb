require "spec_helper"

describe Mongoid::Contextual::Aggregable::Mongo do

  let(:date_str) do
    '2013-05-20'
  end

  let(:date_str_short) do
    '2013-05'
  end

  let(:date) do
    Time.parse(date_str)
  end

  describe "mixed reports" do

    it "should calc # of birthday campaigns divided by total active subscriptions" do
      #number of active businesses
      active_businesses = MonthlyBusinessBilling.aggregates.for_month(date_str_short).with_subscription_status(:active).count

      #number of active BirthdayCampaigns across active businesses
      active_campaigns = Offer.aggregates.for_date(date_str).with_type('BirthdayOffer').group(:business_id).count

      active_campaigns / active_businesses
    end

  end

end