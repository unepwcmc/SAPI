namespace :rsync do
  desc "Rsync of existing directories"
  task :sync do
    on roles(:app) do
      execute "rsync -av --ignore-existing #{release_path}/public/downloads/ #{shared_path}/public/downloads/"
    end
  end
end
