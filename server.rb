# encoding: utf-8
#load the files
$:.push File.expand_path("../lib", __FILE__)


require 'sinatra'
require 'active_support/all'
require 'digest/md5'
require 'rexml/document'
require "date"
require 'data_mapper' # requires all the gems listed above

require 'config'


require './models/article'
require './models/location_message'
require './models/news_message'
require './models/picture_message'
require './models/text_message'

DataMapper.setup(:default, "sqlite3:./db/fumutang.db")
DataMapper.finalize
DataMapper.auto_upgrade!

WeiXin::Config.token = "weixin"
WeiXin::Config.url = "http://weixin.bbtang.com"

class Server < Sinatra::Application
  #token, timestamp, nonce
  def geneate_signature(token,timestamp,nonce)
    signature = [token.to_s,timestamp.to_s,nonce.to_s].sort.join("")
    Digest::SHA1.hexdigest(signature)
  end

  def valid_signature?(signature,timestamp,nonce)
    token = WeiXin::Config.token

    if signature.present? and token.present? and timestamp.present? and nonce.present?
      guess_signature = geneate_signature(token,timestamp,nonce)
      guess_signature.eql? signature
    end
  end

  #http://www.ruby-doc.org/stdlib-1.9.3/libdoc/rexml/rdoc/REXML.html
  #http://www.germane-software.com/software/rexml/docs/tutorial.html
  #==========xml generate

  #
=begin
* signature — 微信加密签名
* timestamp — 时间戳
* nonce — 随机数
* echostr — 随机字符串
=end
  #params
  def present?(val)
    !val.nil? and !val.empty?
  end


  def generate_message(data)
    if data.present?
      data_xml = Hash.from_xml(data)
      message_hash = data_xml["xml"] if data_xml.present? and data_xml.has_key? "xml"
      message_hash = Hash[message_hash.collect{|k,v| [k.underscore,v]}]
      message_hash["create_time"] = Time.at message_hash["create_time"].to_i  if message_hash["create_time"].present?
      message_hash
    end
  end

  def message_class(type)
    messages = {
                 text: TextMessage,
                 image: PictureMessage,
                 news: NewsMessage
               }

    (type.present? and messages.has_key? type.to_sym) ? messages[type.to_sym] : nil
  end

  def save_message(data)
    message_hash = generate_message data
    message = message_class(message_hash["msg_type"])
    if message.present?
      message.create(message_hash)
    end
  end

  ########reply message
  KeyContent = {
                  "今天的亲子刊" => "目前我们每天早上8点只发送当天的亲子早刊。如果您想晚上看到我们的亲子晚刊，请为我们多多邀请您的朋友订阅。人数到了一定程度，就可以同时发早、中、晚刊噢，谢谢您的支持。",
                  "谢谢" => "谢谢您的支持，请为我们多多邀请您的朋友订阅。订阅人数达到一定程度，才能每天发送早、中、晚刊噢。”父母糖豆“才能为您更好地服务。",
                  %w(问题 提问 疑问 请问) => "谢谢您的提问，由于微信平台不支持随时进行一对一的问答，因此无法回复您的紧急提问。但是我们会在周末做一次专刊，从一周内收到的问题中挑选有代表性的进行回答，也希望您邀请更多朋友，共同关注父母堂。谢谢！",
                  "Hello2BizUser" => "感谢您的订阅。小编“父母糖豆”会在每天定时为您送上亲子早刊或周末生活特刊。目前我们只能发一期，主题定位宽泛，让大家都可以来读读学学。订阅量一旦超过5000，就能推出生活午刊和养护晚刊，因此希望您点击右上角“菜单”，把“父母堂”推荐给朋友敬请期待父母堂的精彩内容！",
                 /孕(\d+)周/ => "孕期图片"
               }

  KeyMessage = {
                  "今天的亲子刊" => TextMessage,
                  "谢谢" => TextMessage,
                  %w(问题 提问 疑问 请问) => TextMessage,
                  "Hello2BizUser" => TextMessage,
                  /孕(\d+)周/ => PictureMessage
                  #/孕(\d+)周/ => NewsMessage


               }

  # reuturn match_list [reply_content,match_content,match_key]
  def match_message(content)
    match_list = nil
    if content.present?
      KeyContent.each do |key,content_text|
        case key.class.name
          when "String"
            match_list = [content_text,content,key] if content.include?(key)
          when "Regexp"
            match_list = [content_text,content,key] if content.match(key)
          when "Array"
            match_list = [content_text,content,key] if key.collect{|k| content.include? k}.uniq.compact.include? true
        end
      end
      match_list
    end
  end

  def reply_message(message)
    if message.present? and message.respond_to? :content
      reply_content = match_message(message.content)
      if reply_content.present? and KeyMessage.has_key? reply_content[2]
        key = reply_content[2]
        #puts "match #{reply_content[2]} and  will reply a #{KeyMessage[key]}"
        reply_message = nil
        if KeyMessage[key].name.eql? "TextMessage"
          reply_hash = {
                         to_user_name: message.from_user_name,
                         from_user_name: message.to_user_name,
                         msg_type:       message.msg_type,
                         content:        reply_content[0],
                         create_time:    Time.now.to_i.to_s
                                              
}
          #puts "#{reply_hash}"
          reply_message = TextMessage.create reply_hash
        end
        if  KeyMessage[key].name.eql? "NewsMessage" and key.eql? /孕(\d+)周/
          #pic_url = "http://static.bbtang.com/weixin/images/yun/yun1.jpg"
          yun_number = reply_content[1].match(reply_content[2])[1]
          pic_url = "http://static.bbtang.com/weixin/images/yun/yun#{yun_number}.jpg"
          reply_hash = {
                         to_user_name: message.from_user_name,
                         from_user_name: message.to_user_name,
                         #msg_type:       "news",
                         #pic_url:        pic_url,
                         create_time:    Time.now.to_i.to_s

}
          reply_message = NewsMessage.create reply_hash
          article = reply_message.articles.create({title: "#{reply_content[1]}",pic_url: pic_url, description: "pic #{reply_content[1]}"})
          puts "#{article.pic_url}"
          reply_message.reload
        end
        if  KeyMessage[key].name.eql? "PictureMessage" and key.eql? /孕(\d+)周/
          #pic_url = "http://static.bbtang.com/weixin/images/yun/yun1.jpg"
          yun_number = reply_content[1].match(reply_content[2])[1]
          pic_url = "http://static.bbtang.com/weixin/images/yun/yun#{yun_number}.jpg"
          reply_hash = {
                         to_user_name: message.from_user_name,
                         from_user_name: message.to_user_name,
                         msg_type:       "image",
                         pic_url:        pic_url,
                         create_time:    Time.now.to_i.to_s
                       }
          reply_message = PictureMessage.create reply_hash
        end
        #puts "#{reply_message.weixin_xml}"
        reply_message
      end
    end 
  end


 ##################################

  #curl http://localhost:4567/?nonce=121212121&signature=f3739ef63eaeaafc6e935ab9202f6e0e4bee2c03&timestamp=1356601689&echostr=22222222222222222
  get '/' do
    #token= params[:token]
    if valid_signature?(signature= params[:signature], timestamp = params[:timestamp], nonce= params[:nonce] )
      logger.info("signature is ok and return #{params[:echostr]}")
      puts "signature is ok and return #{params[:echostr]}"
      params[:echostr]
    end
  end

  post '/' do
    #puts Hash.from_xml params
    #puts params
    request.body.rewind  # in case someone already read it
    data = request.body.read
    receive_message =  save_message data
    if receive_message.present?
      puts "receive data #{data}"
      auto_reply_message = reply_message(receive_message)
      if auto_reply_message.present?
        puts "respond with #{auto_reply_message.weixin_xml if  auto_reply_message.present?}"
        auto_reply_message.weixin_xml
      end
    end
  end
end
