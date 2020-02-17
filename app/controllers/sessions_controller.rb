class SessionsController < ApplicationController

  #ログインしているときはwork/mainを実行するように指定
  #ただしSession／newアクションのときのみ
  before_action :require_login, only: %i[index new]

  def new
  end

  def create

    user = User.find_by(login_id: login_params[:login_id])

    if user && user.authenticate(password_params[:password])
      log_in user

      if user.user_type == "admin"
        redirect_to admins_main_path, success: 'ログインしました'
      else
        redirect_to works_main_path, success: 'ログインしました'
      end
    else
      flash.now[:danger]='ログインに失敗しました'
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_path, info: 'ログアウトしました'
  end

  def update

  end

  private
  def log_in(user)
    session[:user_id] = user.id
  end

  def name_params
    params.require(:session).permit(:name)
  end

  def login_params
    params.require(:session).permit(:login_id)
  end

  def password_params
    params.require(:session).permit(:password)
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def require_login
    if logged_in?
      redirect_to works_main_path
    end
  end

end
