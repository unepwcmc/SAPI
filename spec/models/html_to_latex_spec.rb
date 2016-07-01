require 'spec_helper'

describe HtmlToLatex do
  describe :convert do
    subject { HtmlToLatex.convert(input_str) }
    context "when italics" do
      context "when tag closed" do
        let(:input_str) { "Text about <i>Foobarus lolus</i> and friends" }
        specify {
          subject.should == "Text about \\textit{Foobarus lolus} and friends"
        }
      end
      context "when tag not closed" do
        let(:input_str) { "Text about <i>Foobarus lolus and friends" }
        specify {
          subject.should == "Text about \\textit{Foobarus lolus and friends}"
        }
      end
    end
    context "when paragraph" do
      context "when tag closed" do
        let(:input_str) { "Text, <p>paragraph</p> and some more text" }
        specify {
          subject.should == "Text, \\newline paragraph\\newline  and some more text"
        }
      end
      context "when tag not closed" do
        let(:input_str) { "Text, <p>paragraph and some more text" }
        specify {
          subject.should == "Text, \\newline paragraph and some more text"
        }
      end
    end
    context "when latex special characters" do
      context "within tags" do
        let(:input_str) { "<b>Lolus & friends</b>" }
        specify { subject.should == "\\textbf{Lolus \\& friends}" }
      end
      context "outside of tags" do
        let(:input_str) { "<b>Lolus</b> & friends" }
        specify { subject.should == "\\textbf{Lolus} \\& friends" }
      end
    end
  end
end
