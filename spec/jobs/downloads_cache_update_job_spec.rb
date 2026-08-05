require 'spec_helper'

RSpec.describe DownloadsCacheUpdateJob do
  describe '.update_checklist_downloads' do
    def build_generator(recorder, label)
      Class.new do
        define_method(:initialize) do |_params|
          @recorder = recorder
          @label = label
        end

        define_method(:generate) do
          # Record the active locale because checklist generation reads
          # translations and cache keys from I18n.locale, not only from params.
          @recorder << [ @label, I18n.locale.to_s ]
          '/tmp/fake-download'
        end
      end
    end

    specify 'prebuilds each checklist variant under its target locale' do
      recorder = []

      stub_const('Checklist::Pdf', Module.new)
      Checklist::Pdf.const_set(:Index, build_generator(recorder, :pdf_index))
      Checklist::Pdf.const_set(:History, build_generator(recorder, :pdf_history))

      stub_const('Checklist::Csv', Module.new)
      Checklist::Csv.const_set(:Index, build_generator(recorder, :csv_index))
      Checklist::Csv.const_set(:History, build_generator(recorder, :csv_history))

      stub_const('Checklist::Json', Module.new)
      Checklist::Json.const_set(:Index, build_generator(recorder, :json_index))
      Checklist::Json.const_set(:History, build_generator(recorder, :json_history))

      DownloadsCache.update_checklist_downloads

      expect(recorder.size).to eq(18)
      expect(recorder.map(&:last).tally).to eq(
        'en' => 6,
        'es' => 6,
        'fr' => 6
      )
    end
  end
end
