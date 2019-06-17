namespace :trade do

  task :appendix_report => :environment do
    dir = 'tmp/appendix_report'
    Dir.mkdir(dir) unless File.exists?(dir)
    puts "Saving appendix report in #{dir}"
    # (1975..Trade::Shipment.scoped.maximum(:year)).each do |year|
    #   puts year
    #   report = Trade::AppendixReport.new(
    #     Trade::Shipment.where(:year => year)
    #   )
    #   report.export("#{dir}/#{year}.csv")
    # end
    report = Trade::AppendixReport.new(
      Trade::Shipment.all
    )
    report.export("#{dir}/diff.csv", true)
  end

end
