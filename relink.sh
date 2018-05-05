cd ~/projects
if [ ! -d $1 ] ; then echo "$1 does not exist... exiting" ; exit 1 ; fi
rm -f search_pahma
ln -s $1 search_pahma
cd search_pahma
echo now restart apache...
