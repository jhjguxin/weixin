module WeiXin
  module Config
    
    def self.token=(val)
      @@token = val
    end
    
    def self.token
      @@token
    end
    
    def self.url=(val)
      @@url = val
    end
    
    def self.url
      @@url
    end
  end
end
