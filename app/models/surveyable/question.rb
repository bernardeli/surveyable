module Surveyable
  class Question < ActiveRecord::Base
    acts_as_list scope: :survey_id

    FIELD_TYPES = [
      ['Text Field', :text_field],
      ['Text Area Field', :text_area_field],
      ['Select Field', :select_field],
      ['Radio Button Field', :radio_button_field],
      ['Check Box Field', :check_box_field],
      ['Date Field', :date_field]
    ]

    has_many :answers, dependent: :destroy, order: :position
    belongs_to :survey

    validates :content, :field_type, presence: true

    accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: lambda { |a| a[:content].blank? }
  end
end
