require 'rails_helper'

SetupWall
JoinWall
Wall

RSpec.describe WallsController do

  describe "POST create" do
    let(:setup_wall) { class_double("SetupWall").as_stubbed_const(transfer_nested_constants: true) }
    let(:wall) { build(:wall, access_code: 'XXX') }

    context 'with no errors' do
      before do
        allow(setup_wall).to receive(:execute).with(session) { wall }
      end

      before { post :create }

      it { is_expected.to redirect_to wall_path('XXX') }
    end

    context 'with GuestAlreadyHasAWall exception' do
      before do
        allow(setup_wall).to receive(:execute).with(session)
          .and_raise(SetupWall::GuestAlreadyHasAWall)
      end

      before { post :create }
      it { is_expected.to redirect_to root_path }
      it { is_expected.to set_the_flash[:alert] }
    end
  end

  describe "GET show" do
    let(:join_wall) { class_double("JoinWall").as_stubbed_const(transfer_nested_constants: true) }
    let(:wall) { create(:wall) }

    context 'with no errors' do
      before do
        allow(join_wall).to receive(:execute).with(wall, session)
      end

      before { get :show, id: wall.access_code }

      it { is_expected.to respond_with 200 }
    end

    context 'with GuestAlreadyHasAWall exception' do
      before do
        allow(join_wall).to receive(:execute).with(wall, session)
          .and_raise(JoinWall::GuestAlreadyHasAWall)
      end

      before { get :show, id: wall.access_code }

      it { is_expected.to redirect_to root_path }
      it { is_expected.to set_the_flash[:alert] }
    end
  end
end

