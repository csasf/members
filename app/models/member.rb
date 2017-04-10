class Member < ApplicationRecord
  audited
  acts_as_paranoid
  is_impressionable
  has_many :member_instruments, dependent: :destroy
  has_many :member_sets, dependent: :destroy
  has_many :member_notes, dependent: :destroy

  # This maybe should be a has_and_belongs_to_many
  has_many :performance_sets, through: :member_sets

  accepts_nested_attributes_for :member_instruments, allow_destroy: true
  accepts_nested_attributes_for :member_sets, allow_destroy: true
  accepts_nested_attributes_for :member_notes, allow_destroy: true

  validates :first_name, presence: true
  validates_associated :member_sets, message: -> (_obj, _data) { 'Please include an instrument and set name on each set added.' }
  validates_associated :member_instruments, message: -> (_obj, _data) { 'uh oh' }
  validates_date :initial_date, allow_blank: true
  validates_date :waiver_signed, allow_blank: true

  enum statuses: [:untriaged, :placed_in_group, :waitlist, :sub_only, :inactive]

  def self.in_set(performance_set_id)
    Member
      .includes(:member_instruments, :member_sets)
      .where('member_sets.performance_set_id = ?', performance_set_id)
      .references(:member_sets)
  end

  def self.in_set_with_status(performance_set_id, statuses)
    Member.in_set(performance_set_id).where('member_sets.set_status' => statuses)
  end

  def self.filtered_by_criteria(performance_set_id, status_id, instruments = [])
    MemberSet.filtered_by_criteria(performance_set_id, status_id, instruments).map(&:member)
  end

  def to_s
    return program_name if program_name.present?
    return first_name + " " + last_name
  end
end
