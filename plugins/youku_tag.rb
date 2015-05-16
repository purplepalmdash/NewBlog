# Title: youku tag for Jekyll
# Author: liuhui998 http://liuhui998.com
# Description: you can embed youku video to Jekyll
#             (right now, only support flash player) 
#
# Syntax {% youku  video_id  [wdith height]  %}
#
# Example:
# {% youku  XMzM3MDM0Mjg0 480 320   %}
#
# Output:
#

#

module Jekyll

  class YoukuTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @params = markup.split(" ")
      super
    end

    def render(context)
      output = super
      if @params.count>=1
        youku_id = @params[0]
        width = 480
        height = 320
        if @params.count>=3
          width = @params[1]
          height = @params[2]
        end
        
        video = "<object width=\"#{width}\" height=\"#{height}\"><param name=\"movie\" value=\"http://player.youku.com/player.php/sid/#{youku_id}/v.swf\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><param name=\"flashvars\" value=\"\" /><embed src=\"http://player.youku.com/player.php/sid/#{youku_id}/v.swf\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"#{width}\" height=\"#{height}\" flashvars=\"\"></embed></object>";

        return video
      else
        "Error processing input, expected syntax: {% youku youku_id [width] [height] %}"
      end
    end
  end
end

Liquid::Template.register_tag('youku', Jekyll::YoukuTag)
