#
# Cookbook Name:: finalize
# Recipe:: drupal
#
# Copyright 2013, Konstantin Sorokin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may 1obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "drush"

#Base drupal path
drupal_path = node["finalize"]["apache2"]["docroot"]

drush_execute "dl" do
    options %W{drupal
                --default-major=#{node["finalize"]["drupal"]["major_version"]}
                --drupal-project-rename=drupal
                --destination=#{drupal_path}}
end

execute "drupal_extract" do
    command "mv #{drupal_path}/drupal/* #{drupal_path}/drupal/.[^.]* #{drupal_path} && rm -rf #{drupal_path}/drupal"
end

#MySQL dsn
mysql_dsn = "mysql://root"
mysql_dsn << ":#{node.set_unless['mysql']['server_root_password']}"
mysql_dsn << "@localhost/#{node["finalize"]["server_name"]}"

#Install drupal
drush_execute "site-install" do
    cwd drupal_path
    options %W{#{node["finalize"]["drupal"]["install_profile"]}
                --sites-subdir=#{node["finalize"]["drupal"]["sites_subdir"]}
                --account-name=#{node["finalize"]["drupal"]["account_name"]}
                --account-pass=#{node["finalize"]["drupal"]["account_pass"]}
                --db-url=#{mysql_dsn}}
end

# Install bootstrap modules
if node["finalize"]["drupal"]["preferred_state"] == "dev"
    preferred_state = "--dev"
else
    preferred_state = ""
end
modules_list = node["finalize"]["drupal"]["modules_preset"].concat([node["finalize"]["drupal"]["theme"]]).join(",")

# drush pm-download
drush_execute "dl" do
    cwd drupal_path
    options %W{#{modules_list}
                #{preferred_state}
                --default-major=#{node["finalize"]["drupal"]["major_version"]}
                --use-site-dir=#{node["finalize"]["drupal"]["sites_subdir"]}}
end

# drush pm-enable
drush_execute "en" do
    cwd drupal_path
    options %W{#{modules_list}
                --resolve-dependencies}
end
