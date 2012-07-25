require 'spec_helper'

describe PDF do
  before(:each) do
    @pdf1_path = [Rails.root, "/tmp/", SecureRandom.hex(16), ".pdf"].join
    @pdf2_path = [Rails.root, "/tmp/", SecureRandom.hex(16), ".pdf"].join

    Prawn::Document.new do |pdf|
      pdf.start_new_page
      pdf.render_file @pdf1_path
    end

    Prawn::Document.new do |pdf|
      pdf.start_new_page
      pdf.render_file @pdf2_path
    end
  end

  it "should return the number of pages in PDF document" do
    PDF::get_page_count(@pdf1_path).should == 2
  end

  it "should merge two PDF files and return a temporary PDF" do
    PDF::merge_pdfs(@pdf1_path, @pdf2_path).should =~ /.*\/[a-fA-F0-9]{16}\.pdf/
  end

  after(:all) do
    FileUtils.rm @pdf1_path, @pdf2_path
  end
end
