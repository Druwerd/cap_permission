Capistrano::Configuration.instance(true).load do
  set :admin_groups, ["root", "sysadmins", "confmgmt"]

  def user_in_group?(group)
     return false if group.nil?
     puts group
     user = ENV["SUDO_USER"]
     groups = capture("groups #{user}")
     groups.include?(" #{group} ")
  end

  def admin_user?()
     puts admin_groups
     admin_groups.each do |admin_group|
       return true if user_in_group?(admin_group)
     end
     return false
  end
  
  def deployment_user?()
     user = EVN["SUDO_USER"]
     deployment_users.to_a.include?(user)
  end
  
  namespace :permission do
     desc "check user's group membership"
     task :check do
        if (not admin_user? and not user_in_group?(group_name) and not deployment_user?)
           abort "\n\n\n\e[0;31m You do not have proper group membership to run this deployment!  \e[0m\n\n\n"
        end
     end
  end

  if Gem.available?('capistrano-ext')
    after "multistage:ensure", "permission:check"
  else
    on :start, "permission:check"
  end

end