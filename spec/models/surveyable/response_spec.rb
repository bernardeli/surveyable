require 'spec_helper'

module Surveyable
  describe Response do
    it { should belong_to(:survey) }
    it { should belong_to(:respondable) }
    it { should have_many(:response_answers) }
    it { should validate_presence_of(:survey) }

    describe "#generate_token" do
      let(:survey) { create(:survey) }

      it "creates token before create" do
        response = described_class.create(survey: survey)

        response.access_token.should_not be_blank
      end
    end

    describe "#completed?" do
      context "when completed_at is null" do
        let(:response) { build_stubbed(:response, completed_at: nil) }

        it "returns false" do
          response.should_not be_completed
        end
      end

      context "when completed_at is not null" do
        let(:response) { build_stubbed(:response, completed_at: Time.now) }

        it "returns true" do
          response.should be_completed
        end
      end
    end

    describe "#complete!" do
      let(:response) { create(:response) }

      it "sets completed_at" do
        response.complete!
        response.should be_completed
      end
    end

    describe ".completed" do
      let(:response1) { create(:response, completed_at: nil) }
      let(:response2) { create(:response, completed_at: Time.now) }

      it "returns only completed surveys" do
        described_class.completed.should == [response2]
      end
    end

    describe "invitations" do
      context "when invite respondable via email is set to true" do
        before { Surveyable.invite_respondable_via_email = true }

        it "sends email to the respondable" do
          SurveyMailer.should_receive(:invitation).with(kind_of(described_class)).and_return(stub(deliver: true))

          create(:response)
        end
      end

      context "when invite respondable via email is set to false" do
        before { Surveyable.invite_respondable_via_email = false }

        it "does not send email to the respondable" do
          SurveyMailer.should_not_receive(:invitation)

          create(:response)
        end
      end
    end
  end
end
