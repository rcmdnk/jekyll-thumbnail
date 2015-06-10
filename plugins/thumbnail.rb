# Title: Thumbnail tag for Octopress (Jekyll).
# Author: rcmdnk (https://github.com/rcmdnk)
#
# Syntax {% thumbnail [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | "title text" ["alt text"]] %}
# Note: class name with a size or width + height are mandatory.
#
# Examples:
#
# * {% thumbnail /images/big_image.jpg 100 100 %}
#
# This makes /images/thumbnail/big_image_100_100.jpg with 100x100px size,
# and adds HTML:
#
#     <img src="/images/thumbnail/big_image_100_100.jpg" width="100" height="100">
#
# * {% thumbnail my-thumbnail /images/big_image.jpg %}
#
# You can use class name to define the size.
# To use the class, define width/height in your _config.yml like:
#
#     # Thumbnails
#     thumbnails:
#       - my-thumbnail
#     my-thumbnail-width: 200
#     my-thumbnail-height: 200
#
# Give class name to `thumbnails`, and define <class name>-width and <class name>-height.
#
# Then, the tag makes /images/thumbnail/big_image_200_200.jpg with 200x200px size,
# and adds HTML:
#
#     <img class="my-thumbnail" src="/images/thumbnail/big_image_200_200.jpg" width="200" height="200">
#
# * {% thumbnail my-thumbnail /images/big_image.jpg "This is a thumbnail"  "Thumbnail" %}
#
# You can add title/alt like img tag, too.
# This adds:
#
#     <img class="my-thumbnail" src="/images/thumbnail/big_image_200_200.jpg" width="200" height="200" title="This is a thumbnail" alt="Thumbnail">
#
#

module Jekyll

  class Thumbnail < Liquid::Tag
    @img = nil

    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'src', 'width', 'height', 'title']

      if markup =~ /(?<class>\S.*\s+)?(?<src>(?:https?:\/\/|\S*\/|val:)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @img = attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @img['title']
          @img['title']  = title
          @img['alt']    = alt
        else
          @img['alt']    = @img['title'].gsub!(/"/, '&#34;') if @img['title']
        end
        @img['class'].gsub!(/"/, '') if @img['class']
      end
      super
    end

    def render(context)
      site = context.registers[:site]
      if @img
        has_thumbnail_class = false
        if @img['class'] and site.config['thumbnails']
          site.config['thumbnails'].each{ |t|
            if @img['class'].match(t)
              @img['class'].gsub!(t, t + '-img')
              has_thumbnail_class = true
              break
            end
          }
        end
        if (not @img.key?('width') or not @img.key?('height'))
          if not has_thumbnail_class
            raise 'Need width and height or thumbnail class for thumbnail!'
          end
          site.config['thumbnails'].each{ |t|
            if @img['class'].match(t)
              @img['width'] = site.config[t + '-width'].to_s
              @img['height'] = site.config[t + '-height'].to_s
              break
            end
          }
        end
        @img['src'] = context[@img['src'].split(':')[1]] if @img['src'] =~ /^val:/
        if ! (@img['class'] and @img['class'].include?('noimgpath'))
          if site.config['imgpath'] and @img['src'] !~ /^(http|#{site.config['imgpath']})/
            @img['src'] = site.config['imgpath']+@img['src']
          end
        end
        thumbnail = @img['src']
        local_file = site.source + @img['src'].sub(site.config['url'], '')
        if File.exist?(local_file)
          file_path = @img['src'].split('/')
          file_name = file_path[-1]
          thumbnail = file_path[0..-2].join('/') + '/thumbnail/' + file_name.split('.')[0..-2].join('.') + '_' + @img['width'] + '_' + @img['height'] + '.' + file_name.split('.')[-1]
          thumbnail_local = site.source + thumbnail.sub(site.config['url'], '')
          if not File.exist?(thumbnail_local)
            thumbnail_path = thumbnail_local.split('/')
            `mkdir -p #{thumbnail_path[0..-2].join('/')}`
            size = `identify -format "%w %h" #{local_file}`.strip().split()
            w = size[0].to_f
            h = size[1].to_f
            if w > @img['width'].to_f and h > @img['height'].to_f
              if w/@img['width'].to_f > h/@img['height'].to_f
                `convert -strip -thumbnail 'x#{@img['height']}' -crop '#{@img['width']}x#{@img['height']}+0+0' #{local_file} #{thumbnail_local}`
              else
                `convert -strip -thumbnail '#{@img['width']}x' -crop '#{@img['width']}x#{@img['height']}+0+0' #{local_file} #{thumbnail_local}`
              end
            else
              `convert -strip -crop '#{@img['width']}x#{@img['height']}+0+0' #{local_file} #{thumbnail_local}`
            end
            site.static_files << Jekyll::StaticFile.new(site, site.source, thumbnail_path[0..-2].join('/').sub(site.source, ''), thumbnail_path[-1])
          end
          @img['src'] = thumbnail
        end
        "<img #{@img.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}>"
      else
        "Error processing input, expected syntax: {% thumbnail [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('thumbnail', Jekyll::Thumbnail)
