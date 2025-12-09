class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/users/me
  def show
    render json: {
      user: {
        id: current_user.id,
        phone: current_user.phone,
        name: current_user.name,
        email: current_user.email,
        createdAt: current_user.created_at,
        updatedAt: current_user.updated_at
      }
    }, status: :ok
  end

  # PUT /api/v1/users/me
  def update
    if current_user.update(user_params)
      render json: {
        message: 'Profile updated successfully',
        user: {
          id: current_user.id,
          phone: current_user.phone,
          name: current_user.name,
          email: current_user.email
        }
      }, status: :ok
    else
      render json: {
        error: 'Failed to update profile',
        details: current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
