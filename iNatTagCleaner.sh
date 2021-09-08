#!/bin/bash

# version 1.04
# author: Jon Sullivan (jon.j.sullivan@me.com)
# MIT License

# this script cleans up the tags in all the photos in one folder, which I call  "iNat_temp_uploads", removing all tags except those appropriate for uploading to iNaturalist (inaturalist.org) or its New Zealand chapter iNaturalist NZ (inaturalist.nz).

# for this to work, you'll need exiftool installed: http://www.sno.phy.queensu.ca/~phil/exiftool/

# this script retains all tags beginning with "Species|", "Places|", "GeoTagged|", "iNaturalist field|", or "iNaturalist tag|". Every other tag gets removed.

# if you're on a Mac, drag this file onto the Terminal app to run it
# the first time you use it. The first time you use it, you'll also need make it executable using
# chmod 700 scriptme.sh

# first replace any spaces in file names with "_"
for file in /Users/jon/Pictures/iNaturalist_temp_uploads/*.jpg
do
	mv "$file" $(echo $file | tr ' ' '_')
done

# the next code line iteratively loads up each jpg image file in the folder
# change the file path on this line if you're not jonsullivan
# note that I'm using this for images exported from Darktable which always have .jpg in lower case. You'll have to modify this if you have a mix of .JPG and .jpg
for file in /Users/jon/Pictures/iNaturalist_temp_uploads/*.jpg

# for each file in the folder, do the following tag manipulation
do

# make mysubject contain the HierarchicalSubject of the photo
mysubject="$(exiftool $file -HierarchicalSubject)"

# display mysubject, the original hierarchical tags (used in testing the script only)
#echo $mysubject

# add comma to the end (needed for a subsequent search pattern)
mynewsubject="$(echo $mysubject | perl -pe "s/$/,/")"

# remove any EOL taxon tag prefixes inside the taxonomic heirachy of tagged species names.
# for example, "taxonomy:genus=Nyctemera" needs to become just "Nyctemera"
# Otherwise iNaturalist interprets this as the value "Nyctemera" in the field "genus", rather than a valid taxonomic name to match
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:kingdom=//g")"
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:phylum=//g")"
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:class=//g")"
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:order=//g")"
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:family=//g")"
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:subfamily=//g")"
mynewsubject="$(echo $mynewsubject | perl -pe "s/taxonomy:genus=//g")"

# move the species name to an iNaturalist tag by adding "iNaturalist tag|" to the front of it
# species names are at the end of a hierachical tag starting with Species|
# this needs to look for any characters but , between Species and |species name
mynewsubject="$(echo $mynewsubject | perl -pe "s/Species\|[^,]+\|(.+?),/iNaturalist tag|\1,/g")"

# move the place name to an iNaturalist tag by adding "iNaturalist tag|" to the front of it
# place names are at the end of a hierachical tag starting with Places|
# this needs to look for any characters but , between Places and |species name
mynewsubject="$(echo $mynewsubject | perl -pe "s/Places\|[^,]+\|(.+?),/iNaturalist tag|\1,/g")"

# move the geotag tag name to an iNaturalist tag by adding "iNaturalist tag|" to the front of it and removing the Geotag category
# this needs to look for any characters but , between Species and |species name
mynewsubject="$(echo $mynewsubject | perl -pe "s/GeoTagged\|(.+?),/iNaturalist tag|\1,/g")"

# remove all tags before the first one that starts with iNaturalist
mynewsubject="$(echo $mynewsubject | perl -pe "s/.*?(iNaturalist [tf][ia][eg].*$)/\1/")"

# remove all tags after the last one that starts with iNaturalist
mynewsubject="$(echo $mynewsubject | perl -pe "s/(iNaturalist [tf][ia][eg].*\|[A-Za-z ->:=]+?,).*$/\1/")"

# remove any tags not starting with iNaturalist
mynewsubject="$(echo $mynewsubject | perl -pe "s/, (?!iNat).+?, /, /g")"

# repeat the above because this expression only catches every second consecutive instance when there are several matches one after the other
mynewsubject="$(echo $mynewsubject | perl -pe "s/, (?!iNat).+?, /, /g")"

# remove "iNaturalist field|" from the start of all iNaturalist tags
mynewsubject="$(echo $mynewsubject | perl -pe "s/iNaturalist field\|//g")"

# remove "iNaturalist tag|" from the start of all iNaturalist tags
mynewsubject="$(echo $mynewsubject | perl -pe "s/iNaturalist tag\|//g")"

# remove the trailing comma
mynewsubject="$(echo $mynewsubject | perl -pe "s/,$//")"

# display mynewsubject, the iNaturalist-only tags  (used in testing the script only)
#echo $mynewsubject

# now split the remaining tags into an array
# first I need to change ", " to "," to avoid problems with spaces when splitting into an array (otherwise it also splits by spaces in tags)
mynewsubject="$(echo $mynewsubject | perl -pe "s/, /,/g")"
# I can't figure out how to get IFS in bash to ignore spaces so I replace them all with "_"
mynewsubject="$(echo $mynewsubject | perl -pe "s/ /_/g")"
# then I split the tags into an array by ","
OIFS=$IFS # save original IFS settings
IFS=$','
mynewsubject_array=($mynewsubject)
IFS=$OIFS # reset to original IFS settings

# now I put my spaces back
for ((i=0;i<${#mynewsubject_array[*]};i++))
do
    mynewsubject_array[$i]="$(echo ${mynewsubject_array[$i]} | perl -pe 's/_/ /g')"
done

# add each element in the array as a new Subject tag to the image (overwriting the original image each time to leave one file)
# do the same for HierarchicalSubject, since when this is all done there won't be any hierarchy in the tags.
# first clear the original Subject HierarchicalSubject tags from the image
exiftool -overwrite_original $file -Subject=""
exiftool -overwrite_original $file -HierarchicalSubject=""
# now loop through the elements in the array
for ((i=0;i<${#mynewsubject_array[*]};i++))
do
    exiftool -overwrite_original $file -Subject+="${mynewsubject_array[$i]}"
    exiftool -overwrite_original $file -HierarchicalSubject+="${mynewsubject_array[$i]}"
done

done
