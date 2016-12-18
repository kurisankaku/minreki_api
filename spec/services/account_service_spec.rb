require "rails_helper"

describe AccountService do
  include ErrorExamples

  describe "#create" do
    subject { AccountService.create(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:email) { "test@test.test.com" }
    let!(:attrs) do
      { name: "test",
        email: email,
        password: "Abcd1234/",
        password_confirmation: "Abcd1234/" }
    end
    context "email not existed" do
      it "creates new user" do
        expect { subject }.to change(User, :count).by(1)
      end

      it "empty confirmed_at" do
        user = subject
        expect(user.confirmed_at).to be_nil
      end
    end
    context "email exists" do
      context "and not confirmed yet" do
        let!(:user) { create :user, email: email, skip_confirm: false }
        it "updates exists user" do
          expect { subject }.to change(User, :count).by(0)
        end
      end
      context "and confirmed already" do
        let!(:user) { create :user, email: email, skip_confirm: true }
        it "raises not unique error." do
          begin
            subject
            fail
          rescue ActiveRecord::RecordInvalid => e
            expect(e.record.errors.details[:email]).to include(error: :taken, value: email)
          end
        end
      end
    end
    context "skip confirmation" do
      before do
        params[:skip_confirmation] = true
      end
      it "creates new user" do
        expect { subject }.to change(User, :count).by(1)
      end

      it "filled confirmed_at" do
        user = subject
        expect(user.confirmed_at).to be_present
      end

      it "calls skip confirmation!" do
        user = build(:user)
        expect(User).to receive(:new).and_return(user)
        expect(user).to receive(:skip_confirmation!)
        subject
      end
    end
  end

  describe "#authorize" do
    subject { AccountService.authorize(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  email: email,
                  name: name,
                  password: password,
                  password_confirmation: password,
                  current_sign_in_at: current_sign_in_at,
                  last_sign_in_at: last_sign_in_at,
                  locked_at: locked_at,
                  failed_attempts: 4
    }
    let!(:email) { "test@test.test.com" }
    let!(:name) { "test" }
    let!(:password) { "Abcd1234/" }
    let!(:current_sign_in_at) { Time.local(2015, 12, 30) }
    let!(:last_sign_in_at) { Time.local(2015, 12, 29) }
    let!(:locked_at) { Time.local(2015, 12, 31) }
    let!(:attrs) do
      {
        account_name: email,
        password: password
      }
    end
    before { Timecop.freeze(Time.local(2016, 1, 1)) }

    context "authorizes account" do
      context "account found by email" do
        it "updates sign in at and failed attempts, locked at" do
          attrs[:account_name] = email
          user = subject
          expect(user.current_sign_in_at).to eq Time.zone.now
          expect(user.last_sign_in_at).to eq current_sign_in_at
          expect(user.locked_at).to be_nil
          expect(user.failed_attempts).to eq 0
        end
      end
      context "account found by name" do
        it "updates sign in at and failed attempts, locked at" do
          attrs[:account_name] = name
          user = subject
          expect(user.current_sign_in_at).to eq Time.zone.now
          expect(user.last_sign_in_at).to eq current_sign_in_at
          expect(user.locked_at).to be_nil
          expect(user.failed_attempts).to eq 0
        end
      end
    end
    context "account not found" do
      before { params[:account_name] = name + "a" }
      it_behaves_like "bad request error", :invalid_account_name_or_password, :account_name
    end
    context "account is locked" do
      let!(:locked_at) { Time.now + 1.seconds }
      it_behaves_like "bad request error", :account_locked, :account_name
    end
    context "specified password is not correct" do
      before { params[:password] = password + "a" }
      it_behaves_like "bad request error", :invalid_account_name_or_password, :account_name
    end
  end

  describe "#confirm_email" do
    subject { AccountService.confirm_email(token) }
    let!(:user) { create :user, skip_confirm: false }
    let!(:token) { user.confirmation_token }

    before { Timecop.freeze(Time.local(2016, 1, 1)) }

    context "user found by token" do
      it "calls confirm! of user" do
        expect(User).to receive(:find_by_confirmation_token).with(user.confirmation_token).and_return(user)
        expect(user).to receive(:confirm!)
        subject
      end

      it "updates confirmed_at" do
        result = subject
        expect(result.confirmed_at).to eq Time.zone.now
      end
    end
    context "user not found by token" do
      let!(:token) { user.confirmation_token + "a" }
      it_behaves_like "bad request error", :user_not_found, :token
    end
  end

  describe "#update_email" do
    subject { AccountService.update_email(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  email: email,
                  name: name,
                  password: password,
                  password_confirmation: password
    }
    let!(:email) { "test@test.test.com" }
    let!(:name) { "test" }
    let!(:password) { "Abcd1234/" }
    let!(:attrs) do
      {
        id: user.id,
        name: name,
        email: email + "a",
        password: password
      }
    end
    context "specified params is correct" do
      it "updates user unconfirmed_email" do
        result = subject
        expect(result.email).to eq email
        expect(result.unconfirmed_email).to eq(email + "a")
      end
    end
    context "user is not found by id" do
      before { params[:id] = -1 }
      it_behaves_like "bad request error", :user_not_found, :id
    end
  end

  describe "#update_name" do
    subject { AccountService.update_name(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  email: email,
                  name: name,
                  password: password,
                  password_confirmation: password
    }
    let!(:email) { "test@test.test.com" }
    let!(:name) { "test" }
    let!(:password) { "Abcd1234/" }
    let!(:attrs) do
      {
        id: user.id,
        name: name,
        password: password
      }
    end
    context "specified params is correct" do
      it "updates user name" do
        params[:name] = name + "a"
        result = subject
        expect(result.name).to eq(name + "a")
      end
    end
    context "user is not found by id" do
      before { params[:id] = -1 }
      it_behaves_like "bad request error", :user_not_found, :id
    end
    context "specified password is not correct" do
      before { params[:password] = password + "a" }
      it_behaves_like "bad request error", :incorrect, :password
    end
  end

  describe "#update_password" do
    subject { AccountService.update_password(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  email: email,
                  name: name,
                  password: password,
                  password_confirmation: password
    }
    let!(:email) { "test@test.test.com" }
    let!(:name) { "test" }
    let!(:password) { "Abcd1234/" }
    let!(:attrs) do
      {
        id: user.id,
        name: name,
        old_password: password,
        password: password + "a",
        password_confirmation: password + "a"
      }
    end
    context "specified params is correct" do
      it "updates user password" do
        params[:password] = password + "a"
        params[:password_confirmation] = params[:password]
        result = subject
        expect(result.password).to eq(password + "a")
      end
    end
    context "user is not found by id" do
      before { params[:id] = -1 }
      it_behaves_like "bad request error", :user_not_found, :id
    end
    context "specified old password is not correct" do
      before { params[:old_password] = password + "b" }
      it_behaves_like "bad request error", :incorrect, :old_password
    end
  end

  describe "#reset_password" do
    subject { AccountService.reset_password(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  email: email,
                  name: name,
                  password: password,
                  password_confirmation: password,
                  reset_password_token: "token",
                  reset_password_sent_at: Time.zone.now
    }
    let!(:email) { "test@test.test.com" }
    let!(:name) { "test" }
    let!(:password) { "Abcd1234/" }
    let!(:attrs) do
      {
        token: user.reset_password_token,
        password: password + "a",
        password_confirmation: password + "a"
      }
    end

    context "user found by token" do
      it "updates password" do
        user = subject
        expect(user.password).to eq(password + "a")
      end
      it "calls reset_password! of user" do
        expect(User).to receive(:find_by_reset_password_token).with(attrs[:token]).and_return(user)
        expect(user).to receive(:reset_password!).with(attrs[:password], attrs[:password_confirmation])
        subject
      end
    end
    context "user not found by token" do
      before { params[:token] = user.reset_password_token + "a" }
      it_behaves_like "bad request error", :user_not_found, :token
    end
  end

  describe "#issue_reset_password_token" do
    subject { AccountService.issue_reset_password_token(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  email: email,
                  reset_password_token: nil,
                  reset_password_sent_at: nil
    }
    let!(:email) { "test@test.test.com" }
    let!(:attrs) do
      {
        email: email
      }
    end
    context "user found by email" do
      it "reset_password_sent_at and reset_password_token" do
        user = subject
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present
      end
      it "calls issue_reset_password_token! of user" do
        expect(User).to receive(:find_by_email).with(attrs[:email]).and_return(user)
        expect(user).to receive(:issue_reset_password_token!)
        subject
      end
    end
    context "not exists email" do
      before { params[:email] = user.email + "a" }
      it_behaves_like "bad request error", :not_exists, :email
    end
  end

  describe "#delete" do
    subject { AccountService.delete(params) }
    let!(:params) { ActionController::Parameters.new(attrs) }
    let!(:user) { create :user,
                  skip_confirm: true,
                  password: password,
                  password_confirmation: password
    }
    let!(:password) { "Abcd1234/" }
    let!(:attrs) do
      {
        id: user.id,
        password: password
      }
    end
    context "specified params is correct" do
      it "deletes user name" do
        expect { subject }.to change(User, :count).by(-1)
      end
    end
    context "user is not found by id" do
      before { params[:id] = -1 }
      it_behaves_like "bad request error", :user_not_found, :id
    end
    context "specified password is not correct" do
      before { params[:password] = password + "a" }
      it_behaves_like "bad request error", :incorrect, :password
    end
  end
end
