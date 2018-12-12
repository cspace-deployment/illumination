module ApplicationHelper

  def render_csid csid, derivative
      "https://webapps.cspace.berkeley.edu/#TENANT#/imageserver/blobs/#{csid}/derivatives/#{derivative}/content"
  end

  def render_status options={}
      options[:value].collect do |status|
        content_tag(:span, status, style: 'color: red;')
      end.join(', ').html_safe
  end

  def render_media options={}
    # return a list of cards or images
    content_tag(:div) do
      options[:value].collect do |blob_csid|
         content_tag(:a, content_tag(:img, '',
           src: render_csid(blob_csid, 'Medium'),
           class: 'thumbclass'),
           href: "https://webapps.cspace.berkeley.edu/#TENANT#/imageserver/blobs/#{blob_csid}/content",
           target: 'original',
           style: 'padding: 3px;',
           class: 'hrefclass')
      end.join.html_safe
    end
  end

  # use imageserver and blob csid to serve audio
  def render_audio_csid options={}
    # render audio player
    content_tag(:div) do
      options[:value].collect do |audio_csid|
        content_tag(:audio,
          content_tag(:source, "I'm sorry; your browser doesn't support HTML5 audio in MPEG format.",
             src: "https://webapps.cspace.berkeley.edu/#TENANT#/imageserver/blobs/#{audio_csid}/content",
             id: 'audio_csid',
             type: 'audio/mpeg'),
             controls: 'controls',
             style: 'height: 60px; width: 640px;')
      end.join.html_safe
    end
  end

  # use imageserver and blob csid to serve video
  def render_video_csid options={}
    # render video player
    content_tag(:div) do
      options[:value].collect do |video_csid|
        content_tag(:video,
          content_tag(:source, "I'm sorry; your browser doesn't support HTML5 video in MP4 with H.264.",
             src: "https://webapps.cspace.berkeley.edu/#TENANT#/imageserver/blobs/#{video_csid}/content",
             id: 'video_csid',
             type: 'video/mp4'),
             controls: 'controls',
             style: 'width: 640px;')
      end.join.html_safe
    end
  end

  # serve audio directy via apache (apache needs to be configured to serve nuxeo repo
  def render_audio_directly options={}
    # render audio player
    content_tag(:div) do
      options[:value].collect do |audio_md5|
        l1 = audio_md5[0..1]
        l2 = audio_md5[2..3]
        content_tag(:audio,
          content_tag(:source, "I'm sorry; your browser doesn't support HTML5 audio in MPEG format.",
             src: "https://cspace-dev-01.ist.berkeley.edu/#TENANT#_nuxeo/data/#{l1}/#{l2}/#{audio_md5}",
             id: 'audio_md5',
             type: 'audio/mpeg'),
             controls: 'controls',
             style: 'height: 60px; width: 640px;')
      end.join.html_safe
    end
  end

  # serve audio directy via apache (apache needs to be configured to serve nuxeo repo
  def render_video_directly options={}
    # render video player
    content_tag(:div) do
      options[:value].collect do |video_md5|
        l1 = video_md5[0..1]
        l2 = video_md5[2..3]
        content_tag(:video,
          content_tag(:source, "I'm sorry; your browser doesn't support HTML5 video in MP4 with H.264.",
             src: "https://cspace-dev-01.ist.berkeley.edu/#TENANT#_nuxeo/data/#{l1}/#{l2}/#{video_md5}",
             id: 'video_md5',
             type: 'video/mp4'),
             controls: 'controls',
             style: 'width: 640px;')
      end.join.html_safe
    end
  end


  def render_3d options={}
    # render 3d object
    content_tag(:div) do
      options[:value].collect do |d3_csid|
        content_tag(:d3,
          content_tag(:source, "I'm sorry; your browser doesn't support 3D rendering.",
             src: "https://webapps.cspace.berkeley.edu/#TENANT#/imageserver/blobs/#{d3_csid}/content",
             id: 'd3',
             type: 'd3/mpeg'),
             controls: 'controls',
             style: 'width: 640px;')
      end.join.html_safe
    end
  end

end