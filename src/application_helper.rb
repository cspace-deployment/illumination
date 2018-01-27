module ApplicationHelper

  def render_csid csid, derivative
      "https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/#{csid}/derivatives/#{derivative}/content"
  end

  def render_media options={}
    # return a list of cards or images
    content_tag(:div) do
      options[:value].collect do |blob_csid|
         content_tag(:a, content_tag(:img, '',
           src: render_csid(blob_csid, 'Thumbnail'),
           class: 'thumbclass'),
           href: render_csid(blob_csid, 'OriginalJpeg'),
           target: 'originaljpeg',
           style: 'padding: 3px;',
           class: 'hrefclass')
      end.join.html_safe
    end
  end
end