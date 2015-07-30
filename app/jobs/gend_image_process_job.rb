# Job to generate meme images and create thumbnails.
class GendImageProcessJob < ActiveJob::Base
  queue_as do
    gend_image = arguments.first
    if gend_image.src_image.is_animated
      :gend_image_process_animated
    else
      :gend_image_process
    end
  end

  def perform(gend_image)
    gend_image.image = MemeCaptain.meme(
      gend_image.src_image.image,
      gend_image.captions.map(&:text_pos)).to_blob

    gend_image.gend_thumb = make_gend_thumb(gend_image)

    gend_image.work_in_progress = false

    gend_image.save!
  end

  private

  def make_gend_thumb(gend_image)
    thumb_img = gend_image.magick_image_list
    thumb_img.resize_to_fit_anim!(MemeCaptainWeb::Config::THUMB_SIDE)
    gend_thumb = GendThumb.new(image: thumb_img.to_blob)
    thumb_img.destroy!
    gend_thumb
  end
end
