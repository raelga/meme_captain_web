# encoding: UTF-8

# Generated (meme) images controller.
class GendImagesController < ApplicationController
  include SrcImagesHelper

  wrap_parameters GendImage, include: [
    :captions_attributes,
    :private,
    :src_image_id
  ]

  def new
    src_image = SrcImage.without_image.active.find_by!(id_hash: params[:src])
    @src_image_path = url_for(
      controller: :src_images, action: :show, id: src_image.id_hash)
    @src_image_url_with_extension = src_image_url_for(src_image)

    @gend_image = GendImage.new(
      src_image: src_image,
      private: src_image.private)
    MemeCaptainWeb::CaptionBuilder.new.build(@gend_image)
  end

  def index
    if admin?
      @gend_images = admin_index_images
    else
      @gend_images = index_images
    end
  end

  def create
    @gend_image = build_gend_image_for_create
    check_bot_attempt

    if @gend_image.save
      respond_to do |format|
        format.html { redirect_to_page }
        format.json { redirect_to_pending }
      end
    else
      render :new
    end
  end

  def show
    gend_image = GendImage.active.find_by!(id_hash: params[:id])

    expires_in 1.day, public: true

    gend_image_show_headers(gend_image)

    return unless stale?(gend_image)
    render text: gend_image.image, content_type: gend_image.content_type
  end

  def destroy
    gend_image = GendImage.find_by!(id_hash: params[:id])

    if gend_image.user && gend_image.user == current_user
      gend_image.is_deleted = true
      gend_image.save!

      head :no_content
    else
      head :forbidden
    end
  end

  private

  def admin_index_images
    GendImage.without_image.includes(
      :gend_thumb).most_recent.page(params[:page])
  end

  def index_images
    GendImage.without_image.includes(
      :gend_thumb).publick.active.most_recent.page(params[:page])
  end

  def build_gend_image_for_create
    src_image = SrcImage.without_image.active.finished.find_by!(
      id_hash: params[:gend_image][:src_image_id])

    gend_image = src_image.gend_images.build(gend_image_params)
    gend_image.user = current_user
    gend_image
  end

  def check_bot_attempt
    return if params[:gend_image][:email].blank?
    StatsD.increment('bot.attempt'.freeze)
  end

  def gend_image_params
    params.require(:gend_image).permit({ captions_attributes: [
      :font, :text, :top_left_x_pct, :top_left_y_pct, :width_pct,
      :height_pct] }, :private, :email)
  end

  def redirect_to_pending
    status_url = url_for(
      controller: :pending_gend_images,
      action: :show,
      id: @gend_image.id_hash)
    response.status = :accepted
    response.location = status_url
    render(json: { status_url: status_url })
  end

  def redirect_to_page
    redirect_to(
      controller: :gend_image_pages,
      action: :show,
      id: @gend_image.id_hash)
  end

  def gend_image_show_headers(gend_image)
    src_image = SrcImage.without_image.find(gend_image.src_image_id)

    headers.merge!(
      'Meme-Name'.freeze => Rack::Utils.escape(src_image.name),
      'Meme-Source-Image'.freeze => src_image_url_for(src_image),
      'Meme-Text'.freeze => gend_image.meme_text_header)
  end
end
