# == Schema Information
#
# Table name: input_projects
#
#  id                 :integer          not null, primary key
#  crawl_status_id    :integer          default(0), not null
#  github_item_id     :integer          not null
#  name               :integer          not null
#  full_name          :integer          not null
#  owner_id           :integer          not null
#  owner_login_name   :string(255)      not null
#  owner_type         :string(30)       not null
#  github_url         :string(255)      not null
#  is_fork            :boolean          default(FALSE), not null
#  github_description :text(65535)
#  github_created_at  :datetime         not null
#  github_updated_at  :datetime         not null
#  github_pushed_at   :datetime         not null
#  homepage           :text(65535)
#  size               :integer          default(0), not null
#  stargazers_count   :integer          default(0), not null
#  watchers_count     :integer          default(0), not null
#  fork_count         :integer          default(0), not null
#  open_issue_count   :integer          default(0), not null
#  github_score       :string(255)      default(""), not null
#  language           :string(255)      default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class InputProject < ActiveRecord::Base
end