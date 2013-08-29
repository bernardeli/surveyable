module Surveyable
  class Question < ActiveRecord::Base
    acts_as_list scope: :survey_id

    FIELD_TYPES = [
      ['Text Field', :text_field],
      ['Text Area Field', :text_area_field],
      ['Select Field', :select_field],
      ['Radio Button Field', :radio_button_field],
      ['Check Box Field', :check_box_field],
      ['Date Field', :date_field],
      ['Rank Field', :rank_field]
    ]

    has_many :answers, dependent: :destroy, order: :position
    belongs_to :survey

    validates :content, :field_type, presence: true
    validates :minimum, :maximum, presence: true, if: proc { |question| question.field_type == :rank_field }
    validate :maximum_must_be_greater_than_minimum, if: proc { |question| question.field_type == :rank_field }

    scope :reportable_questions, where(field_type: ["select_field", "radio_button_field", "check_box_field"])

    accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: lambda { |a| a[:content].blank? }

    private

    def maximum_must_be_greater_than_minimum
      if maximum && minimum && (maximum < minimum)
        errors.add(:maximum, "Maximum must be greater than minimum")
      end
    end
  end
end
