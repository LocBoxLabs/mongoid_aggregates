require "spec_helper"
require "helpers/business_helper"

Mongoid.protect_sensitive_fields = false

describe Business do

  RSpec.configure do |c|
    c.include BusinessHelper
  end

  context "aggregates on businesses" do
    let(:statuses) do
      ['active', 'delinquent', 'cancelled']
    end

    let(:curr_date) do
      3.months.ago.utc
    end

    before do
      date = curr_date

      (1..100).each_slice(20) do |batch|

        batch.each do |index|
          b = Business.create!(name: "test_#{index}", date: date_to_str(date), business_id: index)
          b.facebook_stats_attributes = {likes: Random.new.rand(10)}
          b.billings_attributes = {
              daily: {gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000)},
              monthly: {gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000)},
              alltime: {gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000)}
          }

          b.subscription = Subscription.new('subscription_id' => Random.new.rand(1000),
                                            :status => statuses[Random.new.rand(2)],
                                            :setup_fee => Random.new.rand(300),
                                            :monthly_subscription_fee => Random.new.rand(300),
                                            :setup_fee_charged_at => Time.now - Random.new.rand(300).days,
                                            :last_status_update => Time.now - Random.new.rand(300).days
          )
          b.subscribers = Subscribers.new(
              daily: {
                  email_count: Random.new.rand(300),
                  active_count: Random.new.rand(300),
                  hardbounce_count: Random.new.rand(300),
                  optout_count: Random.new.rand(300),
                  phone_number_count: Random.new.rand(300),
                  facebook_fan_count: Random.new.rand(300),
                  emails_collected_from_widget: Random.new.rand(300),
                  spam_count: Random.new.rand(300)
              },
              weekly: {
                  email_count: Random.new.rand(300),
                  active_count: Random.new.rand(300),
                  hardbounce_count: Random.new.rand(300),
                  optout_count: Random.new.rand(300),
                  phone_number_count: Random.new.rand(300),
                  facebook_fan_count: Random.new.rand(300),
                  emails_collected_from_widget: Random.new.rand(300),
                  spam_count: Random.new.rand(300)
              },
              monthly: {
                  email_count: Random.new.rand(300),
                  active_count: Random.new.rand(300),
                  hardbounce_count: Random.new.rand(300),
                  optout_count: Random.new.rand(300),
                  phone_number_count: Random.new.rand(300),
                  facebook_fan_count: Random.new.rand(300),
                  emails_collected_from_widget: Random.new.rand(300),
                  spam_count: Random.new.rand(300)
              }

          )
          b.save
        end
        date += 1.month
      end
    end

    it "should find number of active businesses" do
      #TODO: Add for_last_date scope the filters by the last update date of the businesses collection
      Business.aggregates.with_subscription_status(:active).for_date(curr_date).group(nil).sum(:total).should
      eq(Business.with_subscription_status(:active).for_date(curr_date).count)
    end

    it "should find number of delinquent businesses" do
      Business.aggregates.with_subscription_status(:delinquent).group(nil).count.should
      eq(Business.with_subscription_status(:delinquent).count)
    end

    it "should count total email subscribers per business in the last month" do
      businesses = Hash.new 0
      Business.with_subscription_status(:active).each do |b|
        businesses[b.business_id] += b.subscribers.monthly.email_count
      end
      Business.aggregates.with_subscription_status(:active).group('$business_id', count: {'$sum' => '$subscribers.monthly.email_count'}).all.each do |res|
        businesses[res['_id']].should eq(res['count'])
      end
    end

  end
end








