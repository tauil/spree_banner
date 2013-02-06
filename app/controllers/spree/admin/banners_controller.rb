module Spree
  module Admin
    class BannersController < ResourceController
      before_filter :load_data

      def create
        if params[:flash].present?
          puts "\n\n\n\n\n\n\n\nFFFFOOOIII CARALHOOO!!!\n\n\n\n\n\n\n\n\n\n\n"
        else
          invoke_callbacks(:create, :before)
          @object.attributes = params[object_name]
          if @object.save
            invoke_callbacks(:create, :after)
            flash[:success] = flash_message_for(@object, :successfully_created)
            respond_with(@object) do |format|
              format.html { redirect_to location_after_save }
              format.js   { render :layout => false }
            end
          else
            invoke_callbacks(:create, :fails)
            respond_with(@object)
          end
        end
      end

      def update_positions
        params[:positions].each do |id, index|
          Spree::Banner.update_all(['position=?', index], ['id=?', id])
        end

        respond_to do |format|
          format.html { redirect_to admin_banners_url() }
          format.js  { render :text => 'Ok' }
        end
      end

      def load_data
        @banners = Spree::Banner.all
      end

      private
      def location_after_save
        admin_banners_url(@banner)
      end

    end
  end
end
