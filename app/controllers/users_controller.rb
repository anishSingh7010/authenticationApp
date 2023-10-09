class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]
  before_action :authorize, only: %i[ my_account ]

  # POST /users
  def create
  
    @user = User.new(user_params)

    if @user.save
      render json: {email: @user[:email], name: @user[:name], msg: "User created successfully"}, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    # email and password need to be present
    if (!params[:email])
      render json: {msg: "Email is required."}, status: :bad_request
      return
    end

    if (!params[:password])
      render json: {msg: "Password is required."}, status: :bad_request
      return
    end
    
    begin
      @user = User.find_by(email: params[:email])
    rescue Mongoid::Errors::DocumentNotFound => error
      render json: {msg: "User does not exist."}, status: :not_found
      return
    end

    if !@user.authenticate(params[:password])
      render json: {msg: "This combination of username and password is invalid"}, status: :unprocessable_entity
      return
    end

    begin
      token = encode_token
    rescue
      render json: {msg: "Something went wrong. Please try again."}, status: :internal_server_error
      return
    end

    render json: {msg: "Login successful", "email": @user.email, "access_token": token}, status: :ok
  end

  # POST/my-account
  def my_account
    render json: @user, status: :ok
    @user
  end

  def authorize
    # { Authorization: 'Bearer <token>' }, token needs to be present and should have word bearer preceding the token
    token = ''
    begin
    if !request.headers['Authorization']
      raise StandardError.new "Token is not valid"
    end

    auth_header = request.headers['Authorization']
    if auth_header.downcase.include? "bearer"
      token = auth_header.split(' ')[1]
    else
      raise StandardError.new "Token is not valid"
    end
    rescue => error
      render json: {msg: error}, status: :bad_request
      return
    end
    # decode token and compare it's validity
    begin
      decoded_token = decode_token(token)
      email = decoded_token[0]['email']
      @user = User.find_by(email: email)
      rescue => error
        #token decode failed; either token is invalid or expired
        render json: {msg: "Please login again."}, status: :unauthorized  
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
        params.permit(:name, :email, :password, :role, :active, :uniqueActivationId, :resetPasswordId, :password_confirmation)
    end

    def encode_token
      # expiry set after 2 mins
      JWT.encode({email: @user.email}, ENV["ACCESS_TOKEN_SECRET"], "HS256")
    end

    def decode_token(token)
      JWT.decode(token, ENV["ACCESS_TOKEN_SECRET"], true, { algorithm: 'HS256' })
    end
end
