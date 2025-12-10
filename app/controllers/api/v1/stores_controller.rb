module Api
  module V1
    class StoresController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]

      def index
        stores = Store.all.map do |store|
          store_json = store.as_json
          # Add branch_code field, defaulting to 'KKT' if not present
          store_json['branch_code'] = store.respond_to?(:branch_code) ? (store.branch_code || 'KKT') : 'KKT'
          store_json
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
