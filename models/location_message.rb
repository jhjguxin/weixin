class LocationMessage
  include DataMapper::Resource

  property :id,         Serial
  property :to_user_name,  String
  property :from_user_name,      String
  property :msgtype,        String, :default  => "location"
  property :create_time,       Text
  property :location_x,       Float
  property :location_y,       Float
  property :scale,       Integer
  property :label,       String
  property :func_flag,      Integer, :default  => 0
  
  def location_x=(location_x)
    if location_x.is_a?(String)
      super(location_x.to_f)
    else
      super
    end
  end
  def location_y=(location_y)
    if location_y.is_a?(String)
      super(location_y.to_f)
    else
      super
    end
  end
  def weixin_xml
    template_xml = <<Text
<xml>
 <ToUserName><![CDATA[#{to_user_name}]]></ToUserName>
 <FromUserName><![CDATA[#{from_user_name}]]></FromUserName>
 <CreateTime>#{create_time.to_i}</CreateTime>
 <MsgType><![CDATA[#{msg_type}]]></MsgType>
 <Location_X><![CDATA[#{content}]]></Location_X>
 <Location_Y><![CDATA[#{content}]]></Location_Y>
 <Scale>#{scale}</Scale>
 <Label><![CDATA[#{label}]]></Label>
 <FuncFlag><![CDATA[#{func_flag}]]></FuncFlag>
</xml> 
Text
  end
end
