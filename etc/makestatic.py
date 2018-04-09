import csv, sys

template = '''
<td class="splash_td">
<a target="image" href="https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/73775fb8-1ba5-420c-a60a/derivatives/OriginalJpeg/content">
<div class="thumb" style="background-image: url('https://webapps.cspace.berkeley.edu/pahma/imageserver/blobs/73775fb8-1ba5-420c-a60a/derivatives/Medium/content');" title=""></div></a>
<br/><b>Peru :: Gold</b>
<a class="fr" href="?utf8=&search_field=text&q=4-2620">4-2620</a>
</td>
'''


template_old = '''<td class="splash_td">
<a target="image" href="%s">
<div class="thumb" style="background-image: url('%s');" title=""></div></a>
<br/><b><a class="fr" href="%s">%s</a></b>
<!-- a class="fr" href="%s">%s</a -->
</td>'''


template = '''<td class="splash_td">
<a href="%s">
<div class="thumb" style="background-image: url('%s');" title=""></div></a>
<br/><b><a class="fr" href="%s">%s</a></b>
<!-- a class="fr" href="%s">%s</a -->
</td>'''


#file = 'bl.static.txt'
#file = 'bl.static.v2.txt'
#file = 'bl.static.v3.txt'
file = sys.argv[1]

with open(file, 'r') as f1:
    reader = csv.reader(f1, delimiter="|", quoting=csv.QUOTE_NONE, quotechar=chr(255))
    n = 1
    for lineno, row in enumerate(reader):
        # |Netsuke|[canned search|http://xxx]|[link|https://xxxxxx/content]|79| |
        if len(row) < 6: continue
        row = row[:6]
        dummy1, caption, dummy2, search, image, dummy3 = row
        image = image.replace('[link|','')
        #medium = image.replace('OriginalJpeg','Medium')
        search = search.replace('[canned search|','')
        search = search.replace('http://34.217.238.99:3000/','')
        search = search.replace('https://blacklight-dev.ets.berkeley.edu/','')
        original = image
        musno = ''
        filled_in = template % (search,image,search,caption,search,musno)
        if n == 4:
            print '<tr class="grid">'
            n = 0
        n = n + 1
        # hack!
        filled_in = filled_in.replace(']">', '">')
        print filled_in
