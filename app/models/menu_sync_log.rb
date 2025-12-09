class MenuSyncLog < ApplicationRecord
  # Validations
  validates :status, presence: true, inclusion: { in: %w[running success failed] }

  # Scopes
  scope :successful, -> { where(status: 'success') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }
  scope :last_successful, -> { successful.order(completed_at: :desc).first }

  # Instance methods
  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def success?
    status == 'success'
  end

  def failed?
    status == 'failed'
  end

  def running?
    status == 'running'
  end
end
