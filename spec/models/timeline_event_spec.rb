require 'spec_helper'

describe TimelineEvent do
  describe :attributes do
    subject{ TimelineEvent.new(:appendix => 'X', :effective_at => Date.today) }
    specify{ subject.attributes['id'].should_not be_blank }
  end
end