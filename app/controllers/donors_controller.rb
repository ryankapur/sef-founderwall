class DonorsController < ApplicationController
    def show
        @donor = Donor.find(params[:id])
        @tiers = Dedication.tiers
        @donor_published_dedications_by_tier = @donor.published_dedications_by_tier
        @donor_unpublished_dedications_by_tier = @donor.unpublished_dedications_by_tier
        if current_user
            @donor_logged_in = current_user.donor == @donor
        else
            @donor_logged_in = false
        end
        if @donor.status == false
            flash[:error] = "donor"
            redirect_to errors_path
        end
    end
end
