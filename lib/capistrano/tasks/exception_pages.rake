namespace :deploy do
  namespace :assets do
    
    desc "Copy Exception Pages from assests to public folder."
    task :copy_exceptions do
      on roles(:web) do
        within release_path do
          execute :sudo, :cp, "-f public/assets/404.html  public/"
          execute :sudo, :cp, "-f public/assets/422.html  public/"
          execute :sudo, :cp, "-f public/assets/500.html  public/"
        end
      end
    end
    
    after "deploy:compile_assets", "deploy:assets:copy_exceptions"
    
  end
end