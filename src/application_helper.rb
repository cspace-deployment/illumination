module ApplicationHelper

  def render_csid csid
      "https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/#{csid}/derivatives/Thumbnail/content"
  end

  def render_media options={}
    # return a list of cards or images
    content_tag(:div) do
      options[:value].collect do |blob_csid|
        content_tag(:img, '', src: render_csid(blob_csid), style: 'padding: 3px;', class: 'someclass')
      end.join.html_safe
    end
  end
end
