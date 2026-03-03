class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:not_found, :internal_error, :unprocessable]
  
  def not_found
    respond_to do |format|
      format.html { render template: "errors/not_found", layout: false, status: :not_found }
      format.json { render json: { error: "Not Found", message: "The route you requested was not found." }, status: :not_found }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render template: "errors/internal_error", layout: false, status: :internal_server_error }
      format.json { render json: { error: "Internal Server Error", message: "Something went wrong on our end." }, status: :internal_server_error }
    end
  end

  def unprocessable
    respond_to do |format|
      format.html { render template: "errors/unprocessable", layout: false, status: :unprocessable_entity }
      format.json { render json: { error: "Unprocessable Entity", message: "The request was valid but cannot be processed." }, status: :unprocessable_entity }
    end
  end
end
