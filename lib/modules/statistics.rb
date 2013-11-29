module Statistics

  def self.get_total_transactions_per_year		

    trade_transactions = {}
    years = Trade::Shipment.where("year is not null").uniq.pluck(:year)
    years.each{ |y|
     unless y.nil?
      reported_by_exporter = Trade::Shipment.where(:year => y, 
        :reported_by_exporter => true).count
      reported_by_importer = Trade::Shipment.where(:year => y, 
        :reported_by_exporter => false).count
      total_transactions = Trade::Shipment.where(:year => y).count
      trade_transactions[y] = {:total => total_transactions, 
        :reported_by_exporter => reported_by_exporter, 
        :reported_by_importer => reported_by_importer}
     end
     }
     trade_transactions
  end


end