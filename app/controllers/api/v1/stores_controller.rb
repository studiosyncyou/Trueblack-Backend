module Api
  module V1
    class StoresController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        stores = Store.all
        render json: stores, only: [:id, :name, :address, :phone, :latitude, :longitude, :branch_code, :created_at, :updated_at]
      end

      def show
        store = Store.find(params[:id])
        render json: store, include: { categories: { include: :menu_items } }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Store not found" }, status: :not_found
      end
    end
  end
end
