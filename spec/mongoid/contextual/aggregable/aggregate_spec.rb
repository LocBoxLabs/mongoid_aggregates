require "spec_helper"

describe Mongoid::Contextual::Aggregable::Mongo do

  describe Business do

    context "aggregates on businesses" do
      before do
        STATUSES = ['active', 'delinquent', 'cancelled']
        (1..100).each_with_index do |item, index|
          b = Business.create(name: "test_#{index}", date: '2013-05', real_date: Time.now, business_id: index)
          b.facebook_stats_attributes = { likes: Random.new.rand(10) }
          b.billings_attributes = {
              daily: { gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000) },
              monthly: { gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000) },
              alltime: { gross_revenue: Random.new.rand(1000), net_revenue: Random.new.rand(1000) }
          }

          b.subscription = Subscription.new('subscription_id' => Random.new.rand(1000),
                                            :status => STATUSES[Random.new.rand(2)],
                                            :setup_fee => Random.new.rand(300),
                                            :monthly_subscription_fee => Random.new.rand(300),
                                            :setup_fee_charged_at => Time.now - Random.new.rand(300).days,
                                            :last_status_update => Time.now - Random.new.rand(300).days
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
      MonthlyBusinessBilling.aggregates.with_subscription_status(:active).group('$subscription.subscription_id', mrr: {'$last' => '$subscription.mrr_contribution'} ).sum(:mrr).should eq(res.inject(0) {|res, (key,val)| res+val})
    end

    it "should calculate delinquent MRR" do
      res = {}
      MonthlyBusinessBilling.where('subscription.status' => :delinquent).each do |mb|
        res[mb.business_id] = mb.subscription.mrr_contribution unless res.has_key? mb.subscription.subscription_id
      end
      MonthlyBusinessBilling.aggregates.with_subscription_status(:delinquent).group('$subscription.subscription_id', mrr: {'$last' => '$subscription.mrr_contribution'} ).sum(:mrr).should eq(res.inject(0) {|res, (key,val)| res+val})
    end

  end

  describe Offer do
    before do
      STATUSES = ['active', 'delinquent', 'cancelled']
      OFFERTYPES = ['LimitedTimeOffer', 'BirthdayOffer']

      (1..100).each do |index|
        r = Random.new
        now = Time.now - r.rand(90).days
        offer = Offer.new(offer_id: index, business_id: index, date: now, type: OFFERTYPES[r.rand(OFFERTYPES.length)])
        offer.stats = OfferStats.new(

        )
        offer.reservations = OfferReservations.new(

        )
        offer.save
      end
    end
  end
end






