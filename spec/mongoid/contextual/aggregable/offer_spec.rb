require "spec_helper"

describe Offer do
  let(:date) do
    Time.now.strftime('%Y-%m-%d')
  end

  let(:statuses) do
    ['active', 'delinquent', 'cancelled']
  end

  let(:offer_types) do
    ['LimitedTimeOffer', 'BirthdayOffer']
  end

  before do


    (1..100).each do |index|
      r = Random.new
      offer = Offer.new(offer_id: index,
                        business_id: index,
                        date: date,
                        type: offer_types[r.rand(offer_types.length)])
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
      offer.save!
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
  end


end