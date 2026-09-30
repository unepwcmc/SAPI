require 'spec_helper'

RSpec.describe Importer::Logger do
  it 'starts with an empty entries array' do
    expect(described_class.new.entries).to eq([])
  end

  it 'records an error entry, omitting column when not given' do
    logger = described_class.new
    logger.error(row: 3, message: 'boom')

    expect(logger.entries).to eq([ { level: 'error', row: 3, message: 'boom' } ])
  end

  it 'records an error entry with a column' do
    logger = described_class.new
    logger.error(row: 3, column: 'name', message: 'boom')

    expect(logger.entries).to eq([ { level: 'error', row: 3, column: 'name', message: 'boom' } ])
  end

  it 'records a warning entry' do
    logger = described_class.new
    logger.warning(message: 'careful')

    expect(logger.entries).to eq([ { level: 'warning', message: 'careful' } ])
  end

  it 'records a summary entry with every count' do
    logger = described_class.new
    logger.summary(processed: 10, written: 8, skipped: 1, excluded: 1)

    expect(logger.entries).to eq(
      [ { level: 'info', message: 'import completed', processed: 10, written: 8, skipped: 1, excluded: 1 } ]
    )
  end

  it 'accumulates entries across multiple calls, in order, with no Importer::Base involved at all' do
    logger = described_class.new
    logger.error(row: 1, message: 'first')
    logger.warning(message: 'second')
    logger.summary(processed: 1, written: 0, skipped: 0, excluded: 1)

    expect(logger.entries.pluck(:level)).to eq(%w[error warning info])
  end
end
