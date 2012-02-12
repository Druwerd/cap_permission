Capistrano::Configuration.instance(true).load do
  set :group_name, nil
  #set :admin_groups, ["sysadmins", "confmgmt"]

  def user_in_group?(group)
     return false if group.nil?
     user = ENV["SUDO_USER"]
     groups = capture("groups #{user}")
     groups.include?(" #{group} ")
  end

  def admin_user?()
     user_in_group?("sysadmins") or user_in_group?("confmgmt")
  end
  
  namespace :permission do
     desc "check user's group membership"
     task :check do
        if (not admin_user? and not user_in_group?(group_name))
           abort "\n\n\n\e[0;31m You do not have proper group membership to run this deployment!  \e[0m\n\n\n"
        end
     end
  end
  
  on :start, "permission:check"

end