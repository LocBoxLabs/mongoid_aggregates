require "spec_helper"

describe Mongoid::Contextual::Aggregable::Mongo do

  describe Business do

    context "aggregates on businesses" do
      before do
        STATUSES = ['active', 'delinquent', 'cancelled']
        (1..100).each_with_index do |item, index|
          b = Business.create(name: "test_#{index}", date: '2013-05', real_date: Time.now, business_id: index)
          b.facebook_stats_attributes = {likes: Random.new.rand(10)}
          b.billings_attributes = {
              daily: {gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000)},
              monthly: {gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000)},
              alltime: {gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000)}
          }

          b.subscription = Subscription.new('subscription_id' => Random.new.rand(1000),
                                            :status => STATUSES[Random.new.rand(2)],
                                            :setup_fee => Random.new.rand(300),
                                            :monthly_subscription_fee => Random.new.rand(300),
                                            :setup_fee_charged_at => Time.now - Random.new.rand(300).days,
                                            :last_status_update => Time.now - Random.new.rand(300).days
          )
          b.subscribers = BusinessSubscribers.new(
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
      end

      it "should find number of active businesses" do
        #TODO: Add for_last_date scope the filters by the last update date of the businesses collection
        Business.aggregates.with_subscription_status(:active).group(nil, 'total' => {'$sum' => 1}).sum(:total).should
        eq(Business.with_subscription_status(:active).count)
      end

      it "should find number of delinquent businesses" do
        Business.aggregates.with_subscription_status(:delinquent).group(nil).count.should
        eq(Business.with_subscription_status(:delinquent).count)
      end

      it "should count total email subscribers per business for in the last month" do
        businesses = Hash.new 0
        Business.with_subscription_status(:active).each do |b|
          businesses[b.business_id] += b.subscribers.monthly.email_count
        end
        Business.aggregates.with_subscription_status(:active).group(:business_id, count: {'$sum' => '$subscribers.monthly.email_count'}).all.each do |res|
          businesses[res['_id']].should eq(res['count'])
        end
      end

    end
  end

  describe MonthlyBusinessBilling do
    before do
      STATUSES = ['active', 'delinquent', 'cancelled']
      (1..100).each do |index|
        r = Random.new
        now = Time.now - r.rand(90).days
        bb = MonthlyBusinessBilling.new(business_id: index, real_date: now)
        bb.billings = BusinessBillings.new(cc_fee: r.rand(100), lb_commission: r.rand(100), gross_revenue: r.rand(100))
        bb.subscription = BusinessSubscription.new(subscription: r.rand(100), subscription_id: index, mrr_contribution: r.rand(100),
                                                   setup_fee: r.rand(100), monthly_fee: r.rand(100), total: r.rand(100), status: STATUSES[r.rand(STATUSES.length)])
        bb.save
      end
    end

    it "should find number of active subscriptions" do
      MonthlyBusinessBilling.aggregates.with_subscription_status(:active).group('$subscription.subscription_id', 'business' => {'$last' => '$business_id'}).count.should eq(
        MonthlyBusinessBilling.with_subscription_status(:active).count)
    end
    it "should calculate active MRR" do
      res = {}
      MonthlyBusinessBilling.where('subscription.status' => :active).each do |mb|
        res[mb.business_id] = mb.subscription.mrr_contribution unless res.has_key? mb.subscription.subscription_id
      end
      MonthlyBusinessBilling.aggregates.with_subscription_status(:active).group('$subscription.subscription_id', mrr: {'$last' => '$subscription.mrr_contribution'}).sum(:mrr).should eq(res.inject(0) { |res, (key, val)| res+val })
    end

    it "should calculate delinquent MRR" do
      res = {}
      MonthlyBusinessBilling.where('subscription.status' => :delinquent).each do |mb|
        res[mb.business_id] = mb.subscription.mrr_contribution unless res.has_key? mb.subscription.subscription_id
      end
      MonthlyBusinessBilling.aggregates.with_subscription_status(:delinquent).group('$subscription.subscription_id', mrr: {'$last' => '$subscription.mrr_contribution'}).sum(:mrr).should eq(res.inject(0) { |res, (key, val)| res+val })
    end

  end

  describe Offer do
    let (:date) do
      Time.now.strftime('%Y-%m-%d')
    end

    before do
      STATUSES = ['active', 'delinquent', 'cancelled']
      OFFERTYPES = ['LimitedTimeOffer', 'BirthdayOffer']

      (1..100).each do |index|
        r = Random.new
        offer = Offer.new(offer_id: index,
                          business_id: index,
                          date: date,
                          type: OFFERTYPES[r.rand(OFFERTYPES.length)])
        offer.stats = OfferStats.new(
            email_delivery: r.rand(100),
            email_open: r.rand(100),
            email_click: r.rand(100),
            email_bounce: r.rand(100),
            text_delivery: r.rand(100),
            facebook_impressions_paid: r.rand(100),
            facebook_impressions_viral: r.rand(100),
            facebook_impressions_organic: r.rand(100),
            facebook_click: r.rand(100),
            facebook_like: r.rand(100),
            facebook_comment: r.rand(100),
            reach: r.rand(100),
            engagement: r.rand(100)
        )
        offer.reservations = OfferReservations.new(
            daily: {
                count: r.rand(100),
                email_count: r.rand(100),
                email_percent: r.rand(100),
                email_revenue: r.rand(100),
                facebook_percent: r.rand(100),
                gross_revenue: r.rand(100),
                other_percent: r.rand(100),
                total_count: r.rand(100),
                total_revenue: r.rand(100)
            },
            weekly: {
                count: r.rand(100),
                email_count: r.rand(100),
                email_percent: r.rand(100),
                email_revenue: r.rand(100),
                facebook_percent: r.rand(100),
                gross_revenue: r.rand(100),
                other_percent: r.rand(100),
                total_count: r.rand(100),
                total_revenue: r.rand(100)
            },
            monthly: {
                count: r.rand(100),
                email_count: r.rand(100),
                email_percent: r.rand(100),
                email_revenue: r.rand(100),
                facebook_percent: r.rand(100),
                gross_revenue: r.rand(100),
                other_percent: r.rand(100),
                total_count: r.rand(100),
                total_revenue: r.rand(100)
            }
        )
        offer.save
      end
    end

    it "should count total reservations per business" do
      reservations = Hash.new 0

      Offer.all.each do |offer|
        reservations[offer.business_id] += offer.reservations.monthly.count
      end

      res = Offer.aggregates.where(date: date).group('$business_id', :count => {'$sum' => '$reservations.monthly.count'}).all

      res.each do |entry|
        reservations[entry['_id']].should eq(entry['count'])
      end
    end

    it "should count total reservations for LimitedTimeOffer per business" do
      reservations = Hash.new 0

      Offer.where(date: date).where(type: 'LimitedTimeOffer').each do |offer|
        reservations[offer.business_id] += offer.reservations.monthly.count
      end

      res = Offer.aggregates.where(date: date).where(type: 'LimitedTimeOffer').group('$business_id', :count => {'$sum' => '$reservations.monthly.count'}).all

      res.each do |entry|
        reservations[entry['_id']].should eq(entry['count'])
      end
    end

    it "should calculate the gross revenue for all businesses for a specific month" do
      res = Offer.aggregates.where(date: date).group('$business_id', net_revenue: {'$sum' => '$reservations.monthly.gross_revenue'}).all
      puts res
    end


  end

  describe Offer do
    let (:date) do
      Time.now.strftime('%Y-%m-%d')
    end

    let (:r) do
      Random.new
    end

    before do
      STATUSES = ['deleted', 'drafted', 'delivered']

      (1..100).each do |index|
        newsletter = Newsletter.new(business_id: index,
                                    newsletter_id: index,
                                    status: STATUSES[r.rand(STATUSES.length)],
                                    started_at: r.rand(50).days.ago
        )
        newsletter.save
      end
    end

    it "should count all newsletter that were delivered from a certain time for all businesses" do
      Newsletter.aggregates.with_status(:delivered).where(:started_at.gt => 30.days.ago).group(:business_id, count: {'$sum' => 1}).count.should
        eq(Newsletter.where(:started_at.gt => 30.days.ago).with_status(:delivered).count)
    end

  end

  describe Metadata do
    let(:md) do
      Metadata.first
    end

    let (:r) do
      Random.new
    end

    before do
      Metadata.create(
          facebook_demo_last_updated: r.rand(10).days.ago,
          grid_last_updated: r.rand(10).days.ago,
          last_updated: r.rand(10).days.ago,
          last_updated_str: r.rand(10).days.ago.strftime('%Y-%m-%D'),
          type: %w(daily hourly)[r.rand(2)]
      )
    end

    it "should contain metadata" do
      md.facebook_demo_last_updated.should be_a_kind_of(Time)
      md.grid_last_updated.should be_a_kind_of(Time)
      md.last_updated.should be_a_kind_of(Time)
      md.last_updated_str.should be_a_kind_of(String)
      md.last_updated_str.should be_a_kind_of(String)
    end
  end
end






