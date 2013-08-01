# -*- coding: utf-8 -*-
module Spree
  module BannersHelper

    def insert_banner(params={})
      # max items show for list
      max = params[:max] || 1
      # category items show
      category = params[:category] || ""
      # class items show
      cl = params[:class] || "banner"
      # style items show
      style = params[:style] || "list"
      banner = Banner.enable(category).limit(max)
      if !banner.blank?
        if banner.first.attachment_content_type == 'application/x-shockwave-flash'
          if request.headers["HTTP_USER_AGENT"].include?("MSIE")
            raw "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0\" width=\"960\" height=\"270\"><param name=\"movie\" value=\"#{banner.first.attachment.url}\"><param name=\"quality\" value=\"high\"><param name=\"menu\" value=\"false\"></object>"
            else
            raw "<object data=\"#{banner.first.attachment.url}\" width=\"960\" height=\"270\" type=\"application/x-shockwave-flash\" title=\"Adobe Flash Player\"><param name=\"quality\" value=\"high\"><param name=\"menu\" value=\"false\"><param name=\"pluginurl\" value=\"http://www.macromedia.com/go/getflashplayer\"></object>"
          end
        else
          banner = banner.sort_by { |ban| ban.position }
          if (style == "list")
            content_tag(:ul, raw(banner.map do |ban| content_tag(:li, link_to(image_tag(ban.attachment.url(:custom)), ban.url), :class => cl) end.join) )
          else
            raw(banner.map do |ban| content_tag(style.to_sym, link_to(image_tag(ban.attachment.url(:custom)), ban.url), :class => cl) end.join)
          end
        end

      end
    end

  end
end
