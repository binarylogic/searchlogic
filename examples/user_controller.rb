class UserController < ApplicationController
  def index
    @search = User.new_search(params[:search])
    @users, @users_count = @search.all, @search.count
  end
end