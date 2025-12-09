class ApplicationController < ActionController::API
  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    unless token
      return render json: { error: 'No token provided' }, status: :unauthorized
    end

    # TEMPORARY: Accept mock admin token for testing
    if token == 'mock-admin-token-for-testing'
      @current_user = User.find_or_create_by!(phone: '+919999999999') do |user|
        user.name = 'Admin'
      end
      return
    end

    decoded = User.decode_jwt(token)

    unless decoded
      return render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end

    @current_user = User.find_by(id: decoded['user_id'])

    unless @current_user
      return render json: { error: 'User not found' }, status: :unauthorized
    end
  end
end
