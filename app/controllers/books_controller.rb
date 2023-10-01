class BooksController < ApplicationController
  before_action :correct_user, only: [:update, :edit, :destroy]

  before_action :move_to_signed_in


  def show
    @book = Book.find(params[:id])
    @user = @book.user
    @book_comment = BookComment.new
    @book_detail = Book.find(params[:id])
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book_detail.id)
      current_user.view_counts.create(book_id: @book_detail.id)
    end
  end

  def index
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorites).sort_by { |book| -book.favorites.where(created_at: from...to).count }
    @book = Book.new
    @user = current_user
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      redirect_to books_path, flash: { error: @book.errors.full_messages }
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render :edit
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private


  def move_to_signed_in
    unless user_signed_in?
      redirect_to  '/users/sign_in'
    end
  end

  def book_params
    params.require(:book).permit(:title, :body)
  end
end


def correct_user
  @book = Book.find(params[:id])
  @user = @book.user
  redirect_to(books_path) unless @user == current_user
end
