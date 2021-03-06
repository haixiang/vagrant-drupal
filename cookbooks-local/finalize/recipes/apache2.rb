#
# Cookbook Name:: finalize
# Recipe:: apache2
#
# Copyright 2013, Konstantin Sorokin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is d    istributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing perm-*issions and
# limitations under the License.
#

web_app node["finalize"]["server_name"] do
  server_name node["finalize"]["server_name"]
  server_aliases ["*." + node["finalize"]["server_name"]]
  docroot node["finalize"]["apache2"]["docroot"]
  cookbook "apache2"
end