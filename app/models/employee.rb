class Employee < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'EmployeeAuthorizer'

  belongs_to :user
  belongs_to :lab
  validates_presence_of :user, :lab, :job_title
  validates_uniqueness_of :user_id, scope: :lab_id

  after_create :auto_approve_for_admins

  scope :active, -> { includes(:user).with_approved_state.order('LOWER(users.last_name) ASC').references(:user) }

  include Workflow
  workflow do
    state :unverified do
      event :approve, transitions_to: :approved
    end
    state :approved
  end

private

  def auto_approve_for_admins
    approve! if user.present? and user.has_role?(:admin, lab)
  end

end
