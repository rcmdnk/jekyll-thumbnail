# octopress-thumbnail
Thumbnail tag for Octopress (Jekyll).

# Requirement

octopress-thumbnail uses ImageMagick.

To install it, in Mac with Homebrew:

    $ brew install imagemagick

In Cygwin with apt-cyg (in Windows):

    $ apt-cyg install ImageMagick

or as you like.

# Installation

Copy **plugins/thumbnail.rb** to your **plugins** directory.

# Usage

After installing **thumbnail.rb**, you can use `thumbnail` tag in your Markdown files.

Usage is almost same as [img tag](https://github.com/imathis/octopress/blob/master/plugins/image_tag.rb)
in Octopress.

A syntax is:

    {% thumbnail [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | "title text" ["alt text"]] %}

This is same as `img` tag, but
a class name with a size or width and height are necessary.

Examples:

* {% thumbnail /images/big_image.jpg 100 100 %}

This makes **/images/thumbnail/big_image_100_100.jpg** with 100x100px size,
and adds HTML:

    <img src="/images/thumbnail/big_image_100_100.jpg" width="100" height="100">

* {% thumbnail my-thumbnail /images/big_image.jpg %}

You can use class name to define the size.
To use the class, define width/height in your **_config.yml** like:

    # Thumbnails
    thumbnails:
      - my-thumbnail
    my-thumbnail-width: 200
    my-thumbnail-height: 200

Give class name to `thumbnails`, and define `<class name>-width` and `<class name>-height`.

Then, the tag makes **/images/thumbnail/big_image_200_200.jpg** with 200x200px size,
and adds HTML:

    <img class="my-thumbnail" src="/images/thumbnail/big_image_200_200.jpg" width="200" height="200">

* {% thumbnail my-thumbnail /images/big_image.jpg "This is a thumbnail"  "Thumbnail" %}

You can add title/alt like img tag, too.
This adds:

    <img class="my-thumbnail" src="/images/thumbnail/big_image_200_200.jpg" width="200" height="200" title="This is a thumbnail" alt="Thumbnail">

Note:

It keeps a ratio of width/height
and doesn't upsize the file, only shrink the file.

* If the original file is 400x300px, and the thumbnail is 100x100px:
  * Resize it to 133.3x100px, and crop 100x100px from left upper region.
* If the original file is 300x400px, and the thumbnail is 100x100px:
  * Resize it to 100x133.3px, and crop 100x100px from left upper region.
* If the original file is 200x50px, and the thumbnail is 100x100px:
  * Crop 100x100px from left upper region.

# Cleanup Tips

If there is already a thumbnail, `thumbnail` tag doesn't make it.

If you updated the original file, then you need to delete the corresponding thumbnail to update it.

It is useful to modify a cleanup task in your Rakefile of Octopress, like

    desc "Clean out caches: .pygments-cache, .gist-cache, .sass-cache, thumbnail"
    task :clean do
      rm_rf [Dir.glob(".pygments-cache/**"), Dir.glob(".gist-cache/**"), Dir.glob(".sass-cache/**"), "#{source_dir}/stylesheets/screen.css"]
      rm_rf [Dir.glob("#{source_dir}/images/**/thumbnail")]
    end

Then, all thumbnails will be cleaned up by `rake clean`.
