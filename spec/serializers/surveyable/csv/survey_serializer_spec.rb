require 'spec_helper'

describe Surveyable::CSV::SurveySerializer do
  let(:survey) { create(:survey) }
  let(:response1) { create(:response,
                           survey: survey,
                           respondable: create(:person, name: "John"),
                           completed_at: Time.at(1389759443)) }
  let(:response2) { create(:response,
                           survey: survey,
                           respondable: create(:person, name: "Mary"),
                           completed_at: Time.at(1389658686)) }
  let(:question1) { create(:question,
                           survey: survey,
                           content: "Banana",
                           field_type: "text_field") }
  let(:question2) { create(:question,
                           survey: survey,
                           content: "Apple",
                           field_type: "radio_button_field") }
  let(:answer) { create(:answer,
                        question: question2,
                        content: 'good') }

  let!(:response_answer1) { create(:response_answer,
                                   response: response1,
                                   question: question1,
                                   free_content: "Free content mate") }
  let!(:response_answer2) { create(:response_answer,
                                   response: response1,
                                   question: question2,
                                   answer: answer) }

  let!(:response_answer3) { create(:response_answer,
                                   response: response2,
                                   question: question1,
                                   free_content: "Yeah no") }
  let!(:response_answer4) { create(:response_answer,
                                   response: response2,
                                   question: question2,
                                   answer: answer) }

  let(:serializer1) { described_class.new(object: survey,
                                         response_ids: [response1.id, response2.id],
                                         question_ids: [question1.id, question2.id]) }

  let(:serializer2) { described_class.new(object: survey,
                                         response_ids: [response1.id, response2.id],
                                         question_ids: [question1.id]) }

  describe "#csv_headers" do
    context "with all question ids" do
      it "returns headers" do
        serializer1.csv_headers.should == "Subject,Completed Date,Banana,Apple\n"
      end
    end

    context "with not all question ids" do
      it "returns headers" do
        serializer2.csv_headers.should == "Subject,Completed Date,Banana\n"
      end
    end
  end

  describe "#to_csv" do
    context "with all question ids" do
      it "returns answers" do
        serializer1.to_csv.should == "John,15/01/2014 04:17am,Free content mate,good\nMary,14/01/2014 00:18am,Yeah no,good\n"
      end
    end

    context "with not all question ids" do
      it "returns answers" do
        serializer2.to_csv.should == "John,15/01/2014 04:17am,Free content mate\nMary,14/01/2014 00:18am,Yeah no\n"
      end
    end
  end
end
