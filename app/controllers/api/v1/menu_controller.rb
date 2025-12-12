module Api
  module V1
    class MenuController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :sync, :sync_status, :cleanup_duplicates]

      # GET /api/v1/menu?store_id=1
      # Returns cached menu from database (synced from Rista)
      def index
        store_id = params[:store_id]

        # Check if menu needs sync (older than 24 hours)
        check_and_trigger_sync

        # Get menu items from database
        items = MenuItem.available.includes(:category)

        # Filter by store/category if needed
        if params[:category_id].present?
          items = items.where(category_id: params[:category_id])
        end

        render json: transform_menu_response(items)
      end

      # POST /api/v1/menu/sync
      # Manually trigger menu sync (requires authentication)
      def sync
        branch_code = params[:branch_code] || ENV['RISTA_DEFAULT_BRANCH']
        force = params[:force] == 'true' || params[:force] == true

        begin
          result = MenuSyncService.sync_from_rista(branch_code, force: force)

          if result[:skipped]
            render json: {
              message: result[:message],
              skipped: true
            }, status: :ok
          else
            render json: {
              message: 'Menu sync completed successfully',
              items_synced: result[:items_synced],
              duration: result[:duration]
            }, status: :ok
          end

        rescue => e
          Rails.logger.error "[Menu] Sync failed: #{e.message}"
          render json: {
            error: 'Menu sync failed',
            message: e.message
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/menu/sync_status
      # Get status of last sync
      def sync_status
        last_sync = MenuSyncLog.recent.first

        if last_sync
          render json: {
            last_sync: {
              status: last_sync.status,
              items_synced: last_sync.items_synced,
              started_at: last_sync.started_at&.iso8601,
              completed_at: last_sync.completed_at&.iso8601,
              duration: last_sync.duration,
              error_message: last_sync.error_message
            },
            needs_sync: needs_sync?
          }
        else
          render json: {
            last_sync: nil,
            needs_sync: true
          }
        end
      end

      # POST /api/v1/menu/cleanup_duplicates
      # Remove duplicate menu items (keep only Rista-synced items)
      def cleanup_duplicates
        total_items = MenuItem.count
        items_without_rista_code = MenuItem.where(rista_code: nil).count

        Rails.logger.info "[Menu] Cleanup: #{items_without_rista_code} items without rista_code will be deleted"

        deleted_count = MenuItem.where(rista_code: nil).delete_all
        remaining_items = MenuItem.count

        render json: {
          message: 'Duplicate cleanup completed',
          deleted_count: deleted_count,
          total_before: total_items,
          remaining: remaining_items
        }, status: :ok
      end

      private

      def check_and_trigger_sync
        if needs_sync?
          # Trigger background sync (don't wait for it)
          # In production, use ActiveJob
          Thread.new do
            Rails.application.executor.wrap do
              begin
                MenuSyncService.sync_from_rista
              rescue => e
                Rails.logger.error "[Menu] Background sync failed: #{e.message}"
              end
            end
          end
        end
      end

      def needs_sync?
        last_sync = MenuSyncLog.successful.order(completed_at: :desc).first
        last_sync.nil? || last_sync.completed_at < 24.hours.ago
      end

      def transform_menu_response(menu_items)
        # Group items by category
        grouped = menu_items.group_by { |item| item.category }

        categories = grouped.map do |category, items|
          {
            id: category.id,
            name: category.name,
            items: items.map { |item| transform_menu_item(item) }
          }
        end

        {
          categories: categories,
          total_items: menu_items.count,
          last_synced: MenuItem.maximum(:last_synced_at)&.iso8601
        }
      end

      def transform_menu_item(item)
        {
          id: item.id,
          name: item.name,
          shortName: item.short_name,
          description: item.description,
          price: item.price.to_f,
          image: item.image_url,
          isVeg: item.is_veg,
          dietaryType: item.dietary_type,
          allergenInfo: item.allergen_info&.split(',') || [],
          isAvailable: item.is_available,
          categoryId: item.category_id,
          ristaData: {
            code: item.rista_code,
            categoryId: item.rista_category_id,
            subCategoryId: item.rista_subcategory_id
          }
        }
      end
    end
  end
end
