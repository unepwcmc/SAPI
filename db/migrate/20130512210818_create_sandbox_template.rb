class CreateSandboxTemplate < ActiveRecord::Migration
  def change
    create_table :sandbox_template do |t|
      t.string :Appendix_no
      t.string :Taxon_check
      t.string :Term_code
      t.string :Quantity
      t.string :Unit_code
      t.string :Trading_partner_code
      t.string :Origin_country_code
      t.string :Export_permit
      t.string :Origin_permit
      t.string :Purpose_code
      t.string :Source_code
      t.string :Year

      t.timestamps
    end
  end
end
