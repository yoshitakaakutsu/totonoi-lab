class Public::CommentsController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    comment = current_user.comments.new(comment_params)
    comment.post_id = post.id
    if comment.save
      post.create_notification_comment!(current_user, comment.id)
      redirect_to  public_post_path(params[:post_id])
    else
      redirect_to  public_post_path(params[:post_id])
    end
  end

  def destroy
    Comment.find(params[:id]).destroy
    if user_signed_in?
      redirect_to public_post_path(params[:post_id])
    else
      redirect_to admin_post_path(params[:post_id])
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end
end