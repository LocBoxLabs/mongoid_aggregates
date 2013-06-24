require "spec_helper"

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