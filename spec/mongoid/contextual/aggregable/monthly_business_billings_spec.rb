require "spec_helper"

describe MonthlyBusinessBilling do
  let(:statuses) do
    ['active', 'delinquent', 'cancelled']
  end

  before do

    (1..100).each do |index|
      r = Random.new
      now = Time.now - r.rand(90).days
      bb = MonthlyBusinessBilling.new(business_id: index, real_date: now)
      bb.billings = BusinessBillings.new(cc_fee: r.rand(100), lb_commission: r.rand(100), gross_revenue: r.rand(100))
      bb.subscription = BusinessSubscription.new(subscription: r.rand(100), subscription_id: index, mrr_contribution: r.rand(100),
                                                 setup_fee: r.rand(100), monthly_fee: r.rand(100), total: r.rand(100), status: statuses[r.rand(statuses.length)])
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

  it "should calc average subscription price point across all active customers" do
    res = MonthlyBusinessBilling.aggregates.with_subscription_status(:active).for_month('2013-05').group('subscription.subscription_id', subsc: {'$last' => '$subscription.subscription'}).compute(:subsc)

  end

end