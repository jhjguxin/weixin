class NewsMessage
  include DataMapper::Resource

  property :id,             Serial
  property :to_user_name,   String
  property :from_user_name, String
  property :msg_type,       String, :default  => "news"
  property :content,        Text
  property :create_time,    Text
  property :func_flag,      Integer, :default  => 0
  property :aritcle_count,   Integer, :default  => 0
  property :pic_url,        Text
  
  has n, :articles
  
  def weixin_xml
    template_xml = <<Text
<xml>
 <ToUserName><![CDATA[#{to_user_name}]]></ToUserName>
 <FromUserName><![CDATA[#{from_user_name}]]></FromUserName>
 <CreateTime>#{create_time.to_i}</CreateTime>
 <MsgType><![CDATA[#{msg_type}]]></MsgType>
 <Content><![CDATA[]></Content>
 <ArticleCount>#{articles.count}</ArticleCount>
 <Articles>
   #{articles.collect{|a| a.weixin_xml}.join("\n")}
 <Articles>
</xml> 
Text
  end
end
