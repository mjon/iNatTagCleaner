#!/bin/bash

# version 1.0
# author: Jon Sullivan (jon.j.sullivan@me.com)
# Creative Commons CC0

# this script cleans up the tags in all the photos in one folder, which I call  "iNat_temp_uploads", removing all tags except those appropriate for uploading to iNaturalist (inaturalist.org) or its New Zealand chapter NatureWatch NZ (naturewatch.org.nz).

# for this to work, you'll need exiftool installed: http://www.sno.phy.queensu.ca/~phil/exiftool/

# this script retains all tags beginning with "Species|", "Places|", "iNaturalist field|", or "iNaturalist tag|". Every other tag gets removed.

# if you're on a Mac, drag this file onto the Terminal app to run it
# the first time you use it, don't forget to also make it executable using
# chmod 700 scriptme.sh

# iteratively load each jpg image file in the folder
# change the file path in this line if you're not Jon
# note that I'm using this for images exported from Darktable which always have .jpg in lower case. You'll have to modify this if you have a mix of .JPG and .jpg
for file in /Users/jonsullivan/Pictures/iNat_temp_uploads/*.jpg

# for each file in the folder, do the following tag manipulation
do

# make mysubject contain the HierarchicalSubject of the photo
mysubject="$(exiftool $file -HierarchicalSubject)"

# display mysubject, the original hierarchical tags (used in testing the script only)
#echo $mysubject

# add comma to the end (needed for a subsequent search pattern)
mynewsubject="$(echo $mysubject | perl -pe "s/$/,/")"

# move the species name to an iNaturalist tag by adding "iNaturalist tag|" to the front of it
# species names are at the end of a hierachical tag starting with Species|
# this needs to look for any characters but , between Species and |species name
mynewsubject="$(echo $mynewsubject | perl -pe "s/Species\|[^,]+\|(.+?),/iNaturalist tag|\1,/g")"

# move the place name to an iNaturalist tag by adding "iNaturalist tag|" to the front of it
# place names are at the end of a hierachical tag starting with Places|
# this needs to look for any characters but , between Places and |species name
mynewsubject="$(echo $mynewsubject | perl -pe "s/Places\|[^,]+\|(.+?),/iNaturalist tag|\1,/g")"

# remove all tags before the first one that starts with iNaturalist
mynewsubject="$(echo $mynewsubject | perl -pe "s/.*?(iNaturalist [tf][ia][eg].*$)/\1/")"

# remove all tags after the last one that starts with iNaturalist
mynewsubject="$(echo $mynewsubject | perl -pe "s/(iNaturalist [tf][ia][eg].*\|[A-Za-z -:=]+?,).*$/\1/")"

# remove any tags not starting with iNaturalist
mynewsubject="$(echo $mynewsubject | perl -pe "s/, [^i][^N][^a][^t].+?, /, /g")"

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
