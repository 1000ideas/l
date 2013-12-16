# coding: utf-8
module L::Admin
  # Kontroler zarządzający uzytkownikami.
  #
  # Pozwal administratorowi na tworzenie, edycję i usuwanie użytkowników. 
  #
  class UsersController < AdminController
    
    # Akcja wyświetlająca listę wszystkich zarejestrowanych użytkowników
    #
    # *GET* /users/
    def index
      authorize! :read, User
      @users = User

      unless filter(:email).blank?
        @users = @users.where('`users`.`email` LIKE ?', "%#{filter(:email)}%")
      end

      unless filter(:role).blank?
        @users = @users.with_role filter(:role).to_sym
      end

      @users = @users.paginate page: params[:page],
        per_page: 10

      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca informacje o pojedynczym uzytkowniku.
    #
    # *GET* /users/1
    #
    def show
      @user = User.find(params[:id])
      authorize! :read, @user

      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca formularz tworzenia nowego użytkownika.
    #
    # *GET* /users/new
    #
    def new
      @user = User.new
      authorize! :create, @user

      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca formularz edycji istniejącego użytkownika.
    #
    # *GET* /users/1/edit
    #
    def edit
      @user = User.find(params[:id])
      authorize! :update, @user

      respond_to do |format|
        format.html
      end
    end

    # Akcja tworząca nowego uzytkwnika.
    #
    # *POST* /users/1
    #
    def create
      @user = User.new(params[:user])
      authorize! :create, @user

      respond_to do |format|
        if @user.save
          format.html { redirect_to admin_users_path, notice: I18n.t('create.success') }
        else
          format.html { render :action => :new }
        end        
      end
      
    end

    # Akcja aktualizująca istniejącego użytkownika.
    #
    # *PUT* /users/1
    #
    def update
      @user = User.find(params[:id])
      authorize! :update, @user

      @user.updated_by = current_user

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to admin_users_path, notice: I18n.t('update.success') }
        else
          format.html { render :action => :edit }
        end
      end
    end

    # Akcja usuwająca użytkownia.
    #
    # *DELETE* /users/1
    def destroy
      @user = User.find(params[:id])
      authorize! :destroy, @user

      @user.destroy

      respond_to do |format|
        format.html { redirect_to :back, notice: t('delete.success') }
        format.js
      end
    end

    def selection
      authorize! :manage, User
      selection = User.selection_object(params[:selection])

      respond_to do |format|
        if selection.perform!
          format.html { redirect_to :back, notice: t("selection.#{selection.action}.success") }
        else
          format.html { redirect_to :back, alert: t("selection.#{selection.action}.failure") }
        end
      end
    end

  end
end
