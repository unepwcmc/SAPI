class ChangeDigestToPathInDownload < ActiveRecord::Migration
  def up
    rename_column :downloads, :digest, :path
  end

  def down
  end
end
