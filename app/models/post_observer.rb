class PostObserver < ActiveRecord::Observer
  
  def after_create(post)
    if post.topic.user.signed_notifications
      UserMailer.deliver_reply_notification(post.topic.user,post.topic)
    end
  end
  
end