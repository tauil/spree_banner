module Spree
  class Banner < ActiveRecord::Base
    attr_accessible :title, :url, :category, :position, :enabled, :attachment, :attachment_width, :attachment_height
    
    has_attached_file :attachment,
                :url  => "/spree/banner/:id/:basename.:extension",
                :path => "/spree/banner/:id/:basename.:extension"
    
    after_post_process :find_dimensions
    
    validates_presence_of :category, :attachment_width, :attachment_height
    validates_attachment_presence :attachment
    validates_attachment_content_type :attachment, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/jpg', 'image/x-png', 'image/pjpeg', 'application/x-shockwave-flash'], :message => "deve ser JPG, JPEG, PNG, GIF ou SWF"
    
    scope :enable, lambda { |category| {:conditions => {:enabled => true, :category => category}} }
    
    # Load S3 settings
    if (FileTest.exist?(Rails.root.join('config', 's3.yml')) && !YAML.load_file(Rails.root.join('config', 's3.yml'))[Rails.env].blank?)
      S3_OPTIONS = {
              :storage => 's3',
              :s3_credentials => Rails.root.join('config', 's3.yml')
            }
    elsif (FileTest.exist?(Rails.root.join('config', 's3.yml')) && ENV['S3_KEY'] && ENV['S3_SECRET'] && ENV['S3_BUCKET'])
      S3_OPTIONS = {
              :storage => 's3',
              :s3_credentials => {
                :access_key_id     => ENV['S3_KEY'],
                :secret_access_key => ENV['S3_SECRET']
              },
              :bucket => ENV['S3_BUCKET']
            }
    else
      S3_OPTIONS = { :storage => 'filesystem' }
    end
    
    attachment_definitions[:attachment] = (attachment_definitions[:attachment] || {}).merge(S3_OPTIONS)
    
    def initialize(*args)
      super(*args)
      last_banner = Banner.last
      self.position = last_banner ? last_banner.position + 1 : 0
    end
    
    def find_dimensions
      temporary = attachment.queued_for_write[:original]
      filename = temporary.path unless temporary.nil?
      filename = attachment.path if filename.blank?
      unless filename.include?('swf')
        geometry = Paperclip::Geometry.from_file(filename)
        self.attachment_width  = geometry.width
        self.attachment_height = geometry.height
      end
    end
    
  end
end
