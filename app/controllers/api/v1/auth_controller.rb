class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:send_otp, :verify_otp, :refresh_token]

  # POST /api/v1/auth/send-otp
  def send_otp
    phone = params[:phone]

    unless phone.present? && phone.match?(/\A\+?[1-9]\d{1,14}\z/)
      return render json: { error: 'Invalid phone number format. Use E.164 format (e.g., +919876543210)' }, status: :unprocessable_entity
    end

    # Generate OTP and session ID
    otp_code = generate_otp
    session_id = SecureRandom.uuid
    expires_at = 5.minutes.from_now

    # Store OTP session
    otp_session = OtpSession.create!(
      phone: phone,
      otp: otp_code,
      session_id: session_id,
      expires_at: expires_at
    )

    # Send SMS via Twilio
    begin
      send_sms(phone, otp_code)
    rescue => e
      Rails.logger.error("Failed to send OTP SMS: #{e.message}")
      # In development, continue anyway so we can test without Twilio
      unless Rails.env.production?
        Rails.logger.info("DEV MODE: OTP is #{otp_code}")
      end
    end

    render json: {
      message: 'OTP sent successfully',
      sessionId: session_id,
      expiresIn: 300, # 5 minutes in seconds
      # Include OTP in response for development/testing only
      otp: Rails.env.production? ? nil : otp_code
    }, status: :ok
  end

  # POST /api/v1/auth/verify-otp
  def verify_otp
    phone = params[:phone]
    otp = params[:otp]
    session_id = params[:sessionId]
    name = params[:name]

    # Validate inputs
    unless phone.present? && otp.present? && session_id.present?
      return render json: { error: 'Missing required fields' }, status: :unprocessable_entity
    end

    # Find OTP session
    otp_session = OtpSession.find_by(session_id: session_id, phone: phone)

    unless otp_session
      return render json: { error: 'Invalid session' }, status: :unauthorized
    end

    # Verify OTP
    unless otp_session.verify!(otp)
      return render json: {
        error: otp_session.expired? ? 'OTP has expired' : 'Invalid OTP'
      }, status: :unauthorized
    end

    # Find or create user
    user = User.find_by(phone: phone)
    is_new_user = user.nil?

    if is_new_user
      # Create new user
      unless name.present?
        return render json: {
          message: 'Name required for new user',
          isNewUser: true,
          requiresName: true
        }, status: :ok
      end

      user = User.create!(phone: phone, name: name)
    end

    # Generate tokens
    access_token = user.generate_jwt
    refresh_token = user.generate_refresh_token

    render json: {
      message: 'Login successful',
      isNewUser: is_new_user,
      token: access_token,
      refreshToken: refresh_token,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        email: user.email
      }
    }, status: :ok
  end

  # POST /api/v1/auth/refresh-token
  def refresh_token
    refresh_token_string = params[:refreshToken]

    unless refresh_token_string.present?
      return render json: { error: 'Refresh token required' }, status: :unprocessable_entity
    end

    # Find refresh token
    refresh_token_record = RefreshToken.find_by(token: refresh_token_string)

    unless refresh_token_record && !refresh_token_record.expired?
      return render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized
    end

    user = refresh_token_record.user

    # Generate new access token
    new_access_token = user.generate_jwt

    # Optionally rotate refresh token
    # refresh_token_record.destroy
    # new_refresh_token = user.generate_refresh_token

    render json: {
      message: 'Token refreshed successfully',
      token: new_access_token,
      # refreshToken: new_refresh_token, # Uncomment if rotating
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        email: user.email
      }
    }, status: :ok
  end

  # POST /api/v1/auth/logout
  def logout
    refresh_token_string = params[:refreshToken]

    if refresh_token_string.present?
      RefreshToken.find_by(token: refresh_token_string)&.destroy
    end

    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def generate_otp
    # Generate 6-digit OTP
    rand(100000..999999).to_s
  end

  def send_sms(phone, otp)
    return unless ENV['TWILIO_ACCOUNT_SID'].present?

    client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )

    client.messages.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: phone,
      body: "Your TrueBlack verification code is: #{otp}. Valid for 5 minutes."
    )
  end
end
