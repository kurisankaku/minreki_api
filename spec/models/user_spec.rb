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
        model.password_confirmation = "1234567a"
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

  describe "#confirmed?" do
    it "is confirmed" do
      expect(User.new(confirmed_at: Time.zone.now).confirmed?).to be true
    end
    it "is not confirmed" do
      expect(User.new(confirmed_at: nil).confirmed?).to be false
    end
  end

  describe "#generate_confirmation_token_and_confirmation_sent_at" do
    context "call #skip_confirmation!" do
      context "on create" do
        it "doesn't generate token" do
          user = User.new(name: "test", email: "email@test.test.com", password: "Abcd1234/", password_confirmation: "Abcd1234/")
          user.skip_confirmation!
          user.save!
          expect(user.confirmation_token).to be_nil
          expect(user.confirmation_sent_at).to be_nil
        end
      end
      context "on update" do
        let!(:user) { create :user, skip_confirm: true, email: "email@test.test.com" }
        it "doesn't generate token" do
          user.skip_confirmation!
          user.update!(name: "update_name")
          expect(user.confirmation_token).to be_nil
          expect(user.confirmation_sent_at).to be_nil
        end
      end
    end
    context "not call #skip_confirmation!" do
      before { Timecop.freeze(Time.local(2016, 1, 1)) }
      context "on create" do
        it "generate token" do
          user = User.new(name: "test", email: "email@test.test.com", password: "Abcd1234/", password_confirmation: "Abcd1234/")
          user.save!
          expect(user.confirmation_token).to be_present
          expect(user.confirmation_sent_at).to eq Time.local(2016, 1, 1)
        end
      end
      context "on update and not changed email" do
        let!(:user) { create :user, skip_confirm: true, email: "email@test.test.com" }
        it "doesn't generate token" do
          user.update!(name: "update_name")
          expect(user.confirmation_token).to be_nil
          expect(user.confirmation_sent_at).to be_nil
        end
      end
    end
  end

  describe "#send_confirmation_notification" do
    before { Timecop.freeze(Time.local(2016, 1, 1)) }

    context "call #skip_confirmation!" do
      context "on create" do
        it "doesn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user = User.new(name: "test", email: "email@test.test.com", password: "Abcd1234/", password_confirmation: "Abcd1234/")
          user.skip_confirmation!
          user.save!
          expect(user.confirmed_at).to eq Time.local(2016, 1, 1)
        end
      end

      context "on update and not changed email" do
        let!(:user) { create :user, skip_confirm: true, email: "email@test.test.com" }
        it "doesn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.skip_confirmation!
          user.update!(name: "update_name")
        end
      end
    end

    context "not call #skip_confirmation!" do
      context "on create" do
        context "and commits" do
          it "send confirmation mail" do
            message_delivery = instance_double(ActionMailer::MessageDelivery)
            expect(ConfirmationMailer).to receive(:confirmation_instructions).and_return(message_delivery)
            expect(message_delivery).to receive(:deliver_later)

            user = build(:user, skip_confirm: false, email: "email@test.test.com")
            user.save!
            expect(user.confirmed_at).to be_nil
          end
        end

        context "and rollback" do
          it "desn't send confirmation mail" do
            expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
            begin
              ActiveRecord::Base.transaction do
                user = User.new(name: "test", email: "email@test.test.com", password: "Abcd1234/", password_confirmation: "Abcd1234/")
                user.save!
                raise ActiveRecord::Rollback
              end
            rescue ActiveRecord::Rollback
            end
          end
        end
      end

      context "on update and not changed email" do
        let!(:user) { create :user, skip_confirm: true, email: "email@test.test.com" }
        it "desn't send confirmation mail" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.update!(name: "update_name")
        end
      end
    end
  end

  describe "#postpone_email_change_until_confirmation_and_regenerate_confirmation_token" do
    let!(:user) { create :user, skip_confirm: true, email: "email@test.test.com" }

    context "call #skip_confirmation!" do
      it "doesn't generates confirmation token and unconfirmed_email" do
        user.skip_confirmation!
        user.update!(email: "update@test.test.com")
        expect(user.confirmation_token).to be_nil
        expect(user.unconfirmed_email).to be_nil
        expect(user.confirmation_sent_at).to be_nil
      end
    end

    context "not call #skip_confirmation" do
      before { Timecop.freeze(Time.local(2016, 1, 1)) }
      context "when email changed" do
        it "generates confirmation token and unconfirmed_email" do
          user.no_skip_confirmation_notification!
          user.update!(email: "update@test.test.com")
          expect(user.confirmation_token).to be_present
          expect(user.unconfirmed_email).to be_present
          expect(user.email).to eq "email@test.test.com"
          expect(user.unconfirmed_email).to eq "update@test.test.com"
          expect(user.confirmation_sent_at).to eq Time.local(2016, 1, 1)
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
    before { Timecop.freeze(Time.local(2016, 1, 1)) }
    let!(:user) { create :user, skip_confirm: true, email: "email@test.test.com" }

    context "call #skip_confirmation!" do
      context "when email changed" do
        it "desn't send confirmation mail and update email" do
          expect(ConfirmationMailer).not_to receive(:confirmation_instructions)
          user.skip_confirmation!(Time.local(2016, 1, 2))
          user.update!(email: "update@test.test.com")
          expect(user.email).to eq "update@test.test.com"
          expect(user.confirmed_at).to eq Time.local(2016, 1, 2)
        end
      end
    end

    context "not call #skip_confirmation" do
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
            expect(user.confirmed_at).to eq Time.local(2016, 1, 1)
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

  describe "#confirm!" do
    let!(:user) { build :user, skip_confirm: false }
    before { Timecop.freeze(Time.local(2016, 1, 1)) }

    context "already confirmed and unconfirmed_email is blank" do
      it "is invalid confirmed_at" do
        user.confirmed_at = Time.now
        user.unconfirmed_email = nil
        begin
          user.confirm!
        rescue ActiveRecord::RecordInvalid => e
          expect(e.record.errors.details[:confirmed_at]).to include(error: :already_confirmed)
        end
      end
    end

    context "confirmation_sent_at + TOKEN_LIFE_TIME is less than now time" do
      it "is invalid confirmation_token" do
        user.confirmation_sent_at = Time.zone.now - User::TOKEN_LIFE_TIME - 1.seconds
        begin
          user.confirm!
        rescue ActiveRecord::RecordInvalid => e
          expect(e.record.errors.details[:confirmation_token]).to include(error: :expired)
        end
      end
    end

    context "confirmation_sent_at + TOKEN_LIFE_TIME is greater than now time" do
      context "unconfirmed_email presented" do
        it "confirmed" do
          user.confirmation_sent_at = Time.zone.now - User::TOKEN_LIFE_TIME
          user.unconfirmed_email = "update@mail.test.test"
          user.email = "email@mail.test.test"
          user.confirm!

          expect(user.email).to eq "update@mail.test.test"
          expect(user.unconfirmed_email).to be_nil
          expect(user.confirmed_at).to eq Time.zone.now
          expect(user.confirmation_token).to be_nil
        end
      end
      context "unconfirmed_email not presented" do
        it "confirmed" do
          user.confirmation_sent_at = Time.zone.now - User::TOKEN_LIFE_TIME
          user.unconfirmed_email = nil
          user.email = "email@mail.test.test"
          user.confirm!

          expect(user.email).to eq "email@mail.test.test"
          expect(user.unconfirmed_email).to be_nil
          expect(user.confirmed_at).to eq Time.zone.now
          expect(user.confirmation_token).to be_nil
        end
      end
    end
  end

  describe "#issue_reset_password_token!" do
    before { Timecop.freeze(Time.local(2016, 1, 1)) }
    let!(:user) { create :user, skip_confirm: true }

    it "commits" do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(ConfirmationMailer).to receive(:reset_password_instructions).with(instance_of(User), instance_of(String)).and_return(message_delivery)
      expect(message_delivery).to receive(:deliver_later)

      user.issue_reset_password_token!
      expect(user.reset_password_token).to be_present
      expect(user.reset_password_sent_at).to eq Time.zone.now
    end

    it "rollbacks" do
      expect(ConfirmationMailer).not_to receive(:reset_password_instructions)
      begin
        ActiveRecord::Base.transaction do
          user.issue_reset_password_token!
          raise ActiveRecord::Rollback
        end
      rescue ActiveRecord::Rollback
      end
    end
  end

  describe "#reset_password_instructions_require" do
    it "is false when @reset_password_instructions_require is false" do
      user = User.new(reset_password_token: "token", reset_password_sent_at: Time.now)
      user.instance_variable_set(:@reconfirmation_required, false)
      expect(user.send(:reset_password_instructions_require?)).to be false
    end

    it "is false when reset_password_token is nil" do
      user = User.new(reset_password_token: nil, reset_password_sent_at: Time.now)
      user.instance_variable_set(:@reconfirmation_required, true)
      expect(user.send(:reset_password_instructions_require?)).to be false
    end

    it "is false when reset_password_sent_at is nil" do
      user = User.new(reset_password_token: "token", reset_password_sent_at: nil)
      user.instance_variable_set(:@reconfirmation_required, true)
      expect(user.send(:reset_password_instructions_require?)).to be false
    end
  end

  describe "#reset_password!" do
    let!(:user) { build :user }
    before { Timecop.freeze(Time.local(2016, 1, 1)) }

    context "reset_password_sent_at + TOKEN_LIFE_TIME is less than now time" do
      it "is invalid confirmation_token" do
        user.reset_password_sent_at = Time.zone.now - User::TOKEN_LIFE_TIME - 1.seconds
        begin
          user.reset_password!("Password1234/", "Password1234/")
        rescue ActiveRecord::RecordInvalid => e
          expect(e.record.errors.details[:reset_password_token]).to include(error: :expired)
        end
      end
    end

    context "reset_password_sent_at + TOKEN_LIFE_TIME is greater than now time" do
      it "resets password" do
        user.reset_password_sent_at = Time.zone.now - User::TOKEN_LIFE_TIME
        user.reset_password_token = "random token"
        user.reset_password!("Test12345678/", "Test12345678/")

        expect(user.authenticate("Test12345678/")).not_to be false
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end
    end
  end

  describe "locked?" do
    before { Timecop.freeze(Time.local(2016, 1, 1)) }
    it "is false when locked_at is nil" do
      user = User.new(locked_at: nil)
      expect(user.locked?).to be false
    end

    it "is false when locked_at + LOCK_LIFE_TIME is less than now time." do
      user = User.new(locked_at: Time.zone.now - User::LOCK_LIFE_TIME - 1.seconds)
      expect(user.locked?).to be false
    end

    it "is true when locked_at + LOCK_LIFE_TIME eq now time." do
      user = User.new(locked_at: Time.zone.now - User::LOCK_LIFE_TIME)
      expect(user.locked?).to be true
    end

    it "is true when locked_at + LOCK_LIFE_TIME is greater than now time." do
      user = User.new(locked_at: Time.zone.now - User::LOCK_LIFE_TIME + 1.seconds)
      expect(user.locked?).to be true
    end
  end

  describe "increase_failed_attempts!" do
    before { Timecop.freeze(Time.local(2016, 1, 1)) }

    it "increases failed_attempts" do
      user = create(:user, failed_attempts: User::LIMIT_FAILS_COUNT - 1)
      user.increase_failed_attempts!
      expect(user.failed_attempts).to eq User::LIMIT_FAILS_COUNT
    end

    context "when failed_attempts greater than LIMIT_FAILS_COUNT" do
      it "updates locked_at to now time" do
        user = create(:user, failed_attempts: User::LIMIT_FAILS_COUNT + 1, locked_at: Time.local(2015, 12, 31))
        user.increase_failed_attempts!
        expect(user.locked_at).to eq Time.local(2016, 1, 1)
      end
    end

    context "when failed_attempts eq LIMIT_FAILS_COUNT" do
      it "updates locked_at" do
        user = create(:user, failed_attempts: User::LIMIT_FAILS_COUNT, locked_at: Time.local(2015, 12, 31))
        user.increase_failed_attempts!
        expect(user.locked_at).to eq Time.local(2016, 1, 1)
      end
    end

    context "when failed_attempts less than LIMIT_FAILS_COUNT" do
      it "not updates locked_at" do
        user = create(:user, failed_attempts: User::LIMIT_FAILS_COUNT - 1, locked_at: Time.local(2015, 12, 31))
        user.increase_failed_attempts!
        expect(user.locked_at).to eq Time.local(2015, 12, 31)
      end
    end
  end
end
