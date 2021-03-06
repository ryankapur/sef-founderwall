class Users::RegistrationsController < Devise::RegistrationsController
# before_action :configure_sign_up_params, only: [:create]
# before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
   def new
    if params[:donor_id].blank?
     flash[:error] = "You must be a donor to create an account."
     redirect_to root_path
    else
     @donor = Donor.find(params[:donor_id])
     super
    end
   end

  # POST /resource
  def create
    @donor = Donor.find(params[:user][:donor_id])
    if @donor.user != nil
      flash[:error] = "There is already an account associated with this email. Log in or contact an admin."
      redirect_to '/users/sign_up?donor_id=' + params[:user][:donor_id].to_s + '&secret=' + params[:user][:secret]
    elsif params[:user][:secret] != @donor.secret
      flash[:error] = "Invalid secret. Please check the link you received in your email."
      redirect_to '/users/sign_up?donor_id=' + params[:user][:donor_id].to_s + '&secret=' + params[:user][:secret]
    else
      build_resource(sign_up_params)
      resource.donor = @donor
      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        flash[:error] = "Invalid password or nonmatching passwords. Please try again."
        redirect_to '/users/sign_up?donor_id=' + params[:user][:donor_id].to_s + '&secret=' + params[:user][:secret]
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:donor_id])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   donor_path(params[:user][:donor_id])
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
