class ApplicationController < ActionController::API
    rescue_from ActionController::ParameterMissing do |error|
        render json: {"msg": "Send a valid request", "error": error}, status: :bad_request
    end
end