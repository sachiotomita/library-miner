# == Schema Information
#
# Table name: library_relation_errors
#
#  id           :integer          not null, primary key
#  library_name :string(255)      not null
#  error_count  :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class LibraryRelationError < ActiveRecord::Base

  # Relations

  # Validations

  # Scopes

  # Delegates

  # Class Methods

  # Methods
end
