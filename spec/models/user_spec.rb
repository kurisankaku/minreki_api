require 'rails_helper'

describe User do
  describe "#validate" do
    let(:model) { build :user }
    context "name" do
      let!(:user) { create :user, name: "Name" }

      it "is valid when its length 1" do
        model.name = "a"
        expect(model).to be_valid
      end

      it "is valid when its length 128" do
        model.name = "a" * 128
        expect(model).to be_valid
      end

      it "is invalid when its length greater than 129" do
        model.name = "a" * 129
        expect(model).to have(1).errors_on(:name)
      end

      it "is invalid when it is nil" do
        model.name = nil
        expect(model).to have(1).errors_on(:name)
      end

      it "is invalid when it is blank" do
        model.name = ""
        expect(model).to have(1).errors_on(:name)
      end

      it "is invalid when it not unique" do
        model.name = "Name"
        expect(model).to have(1).errors_on(:name)
      end
    end

    context "password" do
      it "is valid when its length 8" do
        model.password = "1234567a"
        expect(model).to be_valid
      end

      it "is invalid when its length 7" do
        model.password = "123456a"
        expect(model).to have(1).errors_on(:password)
      end

      it "is invalid when it is nil" do
        model.password = nil
        expect(model).to have(1).errors_on(:password)
      end

      it "is invalid when it not include number" do
        model.password = "abcdefgh"
        expect(model).to have(1).errors_on(:password)
      end

      it "is invalid when it not include a-zA-Z" do
        model.password = "12345678"
        expect(model).to have(1).errors_on(:password)
      end
    end

    context "email" do
      let!(:user) { create :user, email: "email@test.test.com" }

      it "is invalid when format is invalid" do
        model.email = "test.com"
        expect(model).to have(1).errors_on(:email)
      end

      it "is invalid when it is nil" do
        model.email = nil
        expect(model).to have(1).errors_on(:email)
      end

      it "is invalid when it is blank" do
        model.email = ""
        expect(model).to have(1).errors_on(:email)
      end

      it "is invalid when it not unique" do
        model.email = "email@test.test.com"
        expect(model).to have(1).errors_on(:email)
      end
    end
  end
end
