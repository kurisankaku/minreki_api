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

  describe "#generate_confirmation_token" do
    context "call #skip_confirmation_notification!" do
      context "on create" do
        it "doesn't generate token" do
          user = build(:user, confirm: true, email: "email@test.test.com")
          user.skip_confirmation_notification!
          user.save!
          expect(user.confirmation_token).to be_nil
        end
      end
      context "on update" do
        let!(:user) { create :user, confirm: false, email: "email@test.test.com" }
        it "doesn't generate token" do
          user.skip_confirmation_notification!
          user.update!(name: "update_name")
          expect(user.confirmation_token).to be_nil
        end
      end
    end
    context "not call #skip_confirmation_notification!" do
      context "on create" do
        it "generate token" do
          user = build(:user, confirm: true, email: "email@test.test.com")
          user.save!
          expect(user.confirmation_token).to be_present
        end
      end
      context "on update and not changed email" do
        let!(:user) { create :user, confirm: false, email: "email@test.test.com" }
        it "doesn't generate token" do
          user.update!(name: "update_name")
          expect(user.confirmation_token).to be_nil
        end
      end
    end
  end

  describe "#send_confirmation_notification" do
    context "call #skip_confirmation_notification!" do
      context "on create" do
        it "doesn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user = build(:user, confirm: true, email: "email@test.test.com")
          user.skip_confirmation_notification!
          user.save!
        end
      end

      context "on update and not changed email" do
        let!(:user) { create :user, confirm: false, email: "email@test.test.com" }
        it "doesn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.skip_confirmation_notification!
          user.update!(name: "update_name")
        end
      end
    end

    context "not call #skip_confirmation_notification!" do
      context "on create" do
        context "and commits" do
          it "send confirmation mail" do
            message_delivery = instance_double(ActionMailer::MessageDelivery)
            expect(ConfirmationMailer).to receive(:confirmation_instructions).and_return(message_delivery)
            expect(message_delivery).to receive(:deliver_later)

            user = build(:user, confirm: true, email: "email@test.test.com")
            user.save!
          end
        end

        context "and rollback" do
          it "desn't send confirmation mail" do
            expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
            begin
              ActiveRecord::Base.transaction do
                user = build(:user, confirm: true, email: "email@test.test.com")
                user.save!
                raise ActiveRecord::Rollback
              end
            rescue ActiveRecord::Rollback
            end
          end
        end
      end

      context "on update and not changed email" do
        let!(:user) { create :user, confirm: false, email: "email@test.test.com" }
        it "desn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.update!(name: "update_name")
        end
      end
    end
  end

  describe "#postpone_email_change_until_confirmation_and_regenerate_confirmation_token" do
    let!(:user) { create :user, confirm: false, email: "email@test.test.com" }

    context "call #skip_confirmation_notification!" do
      it "doesn't generates confirmation token and unconfirmed_email" do
        user.skip_confirmation_notification!
        user.update!(email: "update@test.test.com")
        expect(user.confirmation_token).to be_nil
        expect(user.unconfirmed_email).to be_nil
      end
    end

    context "not call #skip_confirmation_notification" do
      context "when email changed" do
        it "generates confirmation token and unconfirmed_email" do
          user.no_skip_confirmation_notification!
          user.update!(email: "update@test.test.com")
          expect(user.confirmation_token).to be_present
          expect(user.unconfirmed_email).to be_present
          expect(user.email).to eq "email@test.test.com"
          expect(user.unconfirmed_email).to eq "update@test.test.com"
        end
      end
      context "when email not changed" do
        it "doesn't generates confirmation token and unconfirmed_email" do
          user.no_skip_confirmation_notification!
          user.update!(name: "updatename")
          expect(user.confirmation_token).to be_nil
          expect(user.unconfirmed_email).to be_nil
        end
      end
    end
  end

  describe "#send_reconfirmation_instructions" do
    let!(:user) { create :user, confirm: false, email: "email@test.test.com" }

    context "call #skip_confirmation_notification!" do
      context "when email changed" do
        it "desn't send confirmation mail and update email" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.skip_confirmation_notification!
          user.update!(email: "update@test.test.com")
          expect(user.email).to eq "update@test.test.com"
        end
      end
    end

    context "not call #skip_confirmation_notification" do
      context "when email changed" do
        context "and commits" do
          it "sends confirmation mail and not update email, but update un_confirmed email" do
            message_delivery = instance_double(ActionMailer::MessageDelivery)
            expect(ConfirmationMailer).to receive(:confirmation_instructions).with(instance_of(User), instance_of(String), { to: "update@test.test.com" }).and_return(message_delivery)
            expect(message_delivery).to receive(:deliver_later)

            user.no_skip_confirmation_notification!
            user.update!(email: "update@test.test.com")

            expect(user.confirmation_token).to be_present
            expect(user.unconfirmed_email).to be_present
            expect(user.email).to eq "email@test.test.com"
            expect(user.unconfirmed_email).to eq "update@test.test.com"
          end
        end

        context "and callback" do
          it "doesn't send confirmation mail, and not update" do
            expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
            begin
              ActiveRecord::Base.transaction do
                user.no_skip_confirmation_notification!
                user.update!(email: "update@test.test.com")
                raise ActiveRecord::Rollback
              end
            rescue ActiveRecord::Rollback
            end
          end
        end
      end
      context "when email not changed" do
        it "doesn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.no_skip_confirmation_notification!
          user.update!(name: "updatename")
        end
      end
    end
  end
end
