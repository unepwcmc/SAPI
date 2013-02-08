require 'spec_helper'

describe TimelineInterval do
  describe :attributes do
    subject{ TimelineInterval.new(:start_pos => 0, :end_pos => 1) }
    specify{ subject.attributes['id'].should_not be_blank }
  end
end