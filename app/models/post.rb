class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :goods, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def favorited_by?(user)
    goods.exists?(user_id: user.id)
  end

  enum status: {published: 0, draft: 1}

  def create_notification_like!(current_user)
    temp = Notification.where(["visitor_id = ? and visited_id = ? and post_id = ? and action = ? ", current_user.id, user_id, id, 'like'])
    if temp.blank?
      notification = current_user.active_notifications.new(
        post_id: id,
        visited_id: user_id,
        action: 'like'
      )
      if notification.visitor_id == notification.visited_id
        notification.checked = true
      end
      notification.save if notification.valid?
    end
  end

  def create_notification_comment!(current_user, comment_id)
    temp_ids = Comment.select(:user_id).where(post_id: id).where.not(user_id: current_user.id).distinct
    temp_ids.each do |temp_id|
      save_notification_comment!(current_user, comment_id, temp_id['user_id'])
    end
    save_notification_comment!(current_user, comment_id, user_id) if temp_ids.blank?
  end

  def save_notification_comment!(current_user, comment_id, visited_id)
    notification = current_user.active_notifications.new(
      post_id: id,
      comment_id: comment_id,
      visited_id: visited_id,
      action: 'comment'
    )
    if notification.visitor_id == notification.visited_id
      notification.checked = true
    end
    notification.save if notification.valid?
  end

  validates :sauna, presence: true
  validates :text, presence: true
  validates :status, presence: true

  def self.search(search)
    if search != ""
      Post.where(['sauna LIKE(?) OR text LIKE(?)', "%#{search}%", "%#{search}%"])
    else
      Post.includes(:user).order('created_at DESC')
    end
  end



end
