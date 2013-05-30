module Surveyable
  class Response < ActiveRecord::Base
    belongs_to :responseable, polymorphic: true
    belongs_to :survey

    has_many :response_answers

    validates :access_token, :survey, presence: true

    before_validation :generate_token, on: :create

    scope :completed, where("completed_at IS NOT NULL")

    after_create :invite_responseable

    def completed?
      !!completed_at
    end

    def complete!
      update_attribute(:completed_at, Time.now)
    end

    private

    def invite_responseable
      SurveyMailer.invitation(self).deliver if Surveyable.invite_responseable_via_email
    end

    def generate_token
      self.access_token = SecureRandom.uuid

      generate_token if Response.where(access_token: self.access_token).any?
    end
  end
end
