Capistrano::Configuration.instance(true).load do
  set :admin_groups, ["root", "sysadmins", "confmgmt"]

  def user_in_group?(group)
     return false if group.nil?
     user = ENV["SUDO_USER"]
     if user.nil?
       puts "\e[0;33m WARNING: 'cap_permission' gem requires you to run cap with sudo\e[0m"
       return false
     end
     groups = capture("groups #{user}").split
     groups.include?(group)
  end

  def admin_user?()
     admin_groups.each do |admin_group|
       return true if user_in_group?(admin_group)
     end
     return false
  rescue NameError => e
     puts "\e[0;33m WARNING: #{e}\e[0m"
     false
  end
  
  def deployment_user?()
     user = ENV["SUDO_USER"]
     deployment_users.to_a.include?(user)
  rescue NameError => e
     puts "\e[0;33m WARNING: #{e}\e[0m"
     false
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