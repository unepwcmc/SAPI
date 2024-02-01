require 'spec_helper'

describe HtmlToLatex do
  describe :convert do
    subject { HtmlToLatex.convert(input_str) }
    context "when italics" do
      context "when tag closed" do
        let(:input_str) { "Text about <i>Foobarus lolus</i> and friends" }
        specify {
          expect(subject).to eq("Text about \\textit{Foobarus lolus} and friends")
        }
      end
      context "when tag not closed" do
        let(:input_str) { "Text about <i>Foobarus lolus and friends" }
        specify {
          expect(subject).to eq("Text about \\textit{Foobarus lolus and friends}")
        }
      end
    end
    context "when paragraph" do
      context "when tag closed" do
        let(:input_str) { "Text, <p>paragraph</p> and some more text" }
        specify {
          expect(subject).to eq("Text, \\newline paragraph\\newline  and some more text")
        }
      end
      context "when tag not closed" do
        let(:input_str) { "Text, <p>paragraph and some more text" }
        specify {
          expect(subject).to eq("Text, \\newline paragraph and some more text")
        }
      end
    end
    context "when latex special characters" do
      context "within tags" do
        let(:input_str) { "<b>Lolus & friends</b>" }
        specify { expect(subject).to eq("\\textbf{Lolus \\& friends}") }
      end
      context "outside of tags" do
        let(:input_str) { "<b>Lolus</b> & friends" }
        specify { expect(subject).to eq("\\textbf{Lolus} \\& friends") }
      end
    end
  end
end
