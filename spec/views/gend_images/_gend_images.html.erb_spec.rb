require 'spec_helper'

describe 'gend_images/_gend_images.html' do

  subject { render :partial => 'gend_images/gend_images' }

  before do
    assign :gend_images, Kaminari.paginate_array([]).page(1)
    assign :show_toolbar, show_toolbar
  end

  context 'when toolbar is enabled' do
    let(:show_toolbar) { true }

    it 'shows the toolbar' do
      subject

      expect(rendered).to have_selector '.btn-toolbar'
    end

  end

  context 'when the toolbar is disabled' do
    let(:show_toolbar) { false }

    it 'does not show the toolbar' do
      subject

      expect(rendered).to_not have_selector '.btn-toolbar'
    end

  end

end
