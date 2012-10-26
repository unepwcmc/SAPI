class AddDigestToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :digest, :string
  end
end
