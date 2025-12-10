module Api
  module V1
    class StoresController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        stores = Store.all.map do |store|
          {
            id: store.id,
            name: store.name,
            space_name: store.space_name,
            area: store.area,
            address: store.address,
            phone: store.phone,
            latitude: store.latitude&.to_f,
            longitude: store.longitude&.to_f,
            hours: store.hours,
            branch_code: store.branch_code || 'KKT' # Default to KKT if not set
          }
        end
        render json: stores
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
