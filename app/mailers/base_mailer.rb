class BaseMailer < ActionMailer::Base
  default from: '2778182976@qq.com'
  default charset: "utf-8"
  default content_type: "text/html"
end