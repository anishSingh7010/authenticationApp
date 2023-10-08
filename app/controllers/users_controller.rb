class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # POST /users
  def create
  
    @user = User.new(user_params)

    if @user.save
      render json: {email: @user[:email], name: @user[:name], msg: "User created successfully"}, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

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

    puts params[:email]
    
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
      JWT.encode({email: @user.email}, ENV["ACCESS_TOKEN_SECRET"], "HS256")
    end
end
