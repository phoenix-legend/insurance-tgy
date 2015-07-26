class BaseMailer < ActionMailer::Base
  default from: 'noreply@ikidstv.com'
  default charset: "utf-8"
  default content_type: "text/html"
end