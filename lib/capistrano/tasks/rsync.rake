namespace :rsync do
desc "Rsync of downloads subfolders"
on roles(:app), in: :sequence, wait: 5 do
task :sync do
execute "rsync -av --ignore-existing #{release_path}/public/downloads/ #{shared_path}/public/downloads/"
execute "rsync -av --ignore-existing #{release_path}/public/cites_trade_guidelines/ #{shared_path}/public/cites_trade_guidelines/"
  end
 end
end
