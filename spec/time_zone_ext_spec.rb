require 'spec_helper'
require 'timecop'

describe TimeZoneExt do
  before(:each) do
    Time.zone = 'EST'
  end

  it "parses time with timezone specified by name" do
    Time.zone.strptime("2012-06-02 00:00 UTC", "%Y-%m-%d %H:%M %Z").to_s.should == "2012-06-01 19:00:00 -0500"
  end

  it "parses time with timezone specified by offset" do
    Time.zone.strptime("2012-06-02 00:00 +0100", "%Y-%m-%d %H:%M %z").to_s.should == "2012-06-01 18:00:00 -0500"
  end

  it "parses time without explicitly specified timezone" do
    Time.zone.strptime("2012-06-02 00:00", "%Y-%m-%d %H:%M").to_s.should == "2012-06-02 00:00:00 -0500"
  end

  it "parses time with named time zone" do
    Time.zone = "Moscow"
    Time.zone.strptime("2012-06-02 00:00", "%Y-%m-%d %H:%M").to_s.should == "2012-06-02 00:00:00 +0400"
  end

  context "when in the US Eastern Time zone" do
    before(:each) { Time.zone = "America/New_York" }
    after  { Timecop.return }
    let(:specified_format) { "%Y-%m-%d %H:%M" }

    context "when it is daylight savings time" do
      before { Timecop.travel(Date.new(2012, 6, 1)) }

      it "round-trips dates also in daylight savings time" do
        timestamp = "2012-06-02 10:00"
        Time.zone.strptime(timestamp, specified_format).to_s.should == "#{timestamp}:00 -0400"
        Time.zone.strptime(timestamp, specified_format).strftime(specified_format).should == timestamp
      end

      it "round-trips dates not in daylight savings time" do
        timestamp = "2012-02-01 10:00"
        Time.zone.strptime(timestamp, specified_format).to_s.should == "#{timestamp}:00 -0500"
        Time.zone.strptime(timestamp, specified_format).strftime(specified_format).should == timestamp
      end
    end

    context "when it is not daylight savings time" do
      before { Timecop.travel(Date.new(2012, 1, 1)) }

      it "round-trips dates in daylight savings time" do
        timestamp = "2012-06-02 10:00"
        Time.zone.strptime(timestamp, specified_format).to_s.should == "#{timestamp}:00 -0400"
        Time.zone.strptime(timestamp, specified_format).strftime(specified_format).should == timestamp
      end

      it "round-trips dates also not in daylight savings time" do
        timestamp = "2012-02-01 10:00"
        Time.zone.strptime(timestamp, specified_format).to_s.should == "#{timestamp}:00 -0500"
        Time.zone.strptime(timestamp, specified_format).strftime(specified_format).should == timestamp
      end
    end
  end
end
