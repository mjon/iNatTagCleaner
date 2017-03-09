# iNatTagCleaner

## What's it for
iNaturalist (http://inaturalist.org) is a great place to post nature observations. Its photo upload tool imports all the tags in photos, unless you manually edit them out during upload. That is tedious when bulk uploading lots of photos that contain some inappropriate tags (like people's names or machine tags that get misinterpreted by iNat). To save time, this bash script strips all the tags from my photos except my iNaturalist tags.

I only want a subset of my tags included in my uploads. For example, I don't want people's names shared, but I still want to tag them on my computer. I've also got personal and curation tags (like whether or not a photo has been shared on Flickr). These clutter up iNat. I also add EOL higher taxonomy tags to my photos so I can search for higher taxa when I need to (I'm a biologist) but these are both unncessary on iNat and get misinterpreted as field data (for example, "taxonomy:kingdom=Animalia" gets turned into the entry "Animalia" in the field "kingdom" which iNat doesn't need).

My bash script iNatTagCleaner is my solution to this. It takes a folder of jpg images exported from my photolibrary and uses exiftool to remove all tags from these photos except the tags I want to go to iNaturalist. I can then drop all those photos onto iNat and push "Submit", usually without any manual editing.

## How this fits into my iNaturalist workflow
My photo workflow is as follows.

1. Import photos to Darktable (http://www.darktable.org/)

2. Geotag DSLR photos without locations using GPX files (I track where I go using the Cyclemeter app on my iPhone)

3. Add lots of tags to my photos (dragged onto photos from my big tag library of taxonomy, locations, and other things I've imported from various sources over the years). 
  - This includes the place name, entered as a hierarchical tag in Darktable starting with "Places|", e.g., "Places|New Zealand|South Island|Canterbury|Banks Peninsula|Akaroa harbour|Hinewai Reserve". iNat just needs "Hinewai Reserve".
  - It also contains heirarchical tags for the notable species in the photo, tagged starting with "Species|" and including EOL machine tags for the higher taxonomy, e.g., "Species|taxonomy:kingdom=Animalia|taxonomy:phylum=Arthropoda|taxonomy:class=Insecta|taxonomy:order=Lepidoptera|taxonomy:family=Erebidae|taxonomy:genus=Nyctemera|taxonomy:binomial=Nyctemera annulata|taxonomy:common=Magpie moth|Magpie moth|Nyctemera annulata". iNat just needs "Nyctemera annulata". 
  - Any tags I want shared as tags in iNaturalist get prefaced with "iNaturalist tag|" (e.g. "iNaturalist tag|Garden"). 
  - Any tags I want to become observation field values in iNaturalist (http://inaturalist.org/observation_fields) start with "iNaturalist field|", e.g., "iNaturalist field|Insect life stage=adult" (an observation field needs to already exist on iNat for that to work). 
  - None of my other tags, like the people in the photo, or the event name, or my tags tracking where I've shared a photo, match those Place, Species, or iNaturalist formats.

4. Export the photos I want to send to iNaturalist to one folder on my computer

5. Run my bash script 'iNatTagCleaner.sh' in the Terminal app on my Mac. It automatically strips out all the tags except those starting with "iNaturalist field|", "iNaturalist tag|", "Species|", and "Places|" from all the photos in the folder, using the awesome power of exiftool (http://www.sno.phy.queensu.ca/~phil/exiftool/).

6. All those photos are then dragged onto the iNaturalist add observation page (https://www.inaturalist.org/observations/upload), which automatically assigns each observation a species name from my tags, gets any observation field values from my tags, and it adds all my tags as observation tags. The only manual thing to do, if necessary, is to combine multiple photos into single observations. Submit, delete the exported images from my iNaturalist folder, and I'm done.

## Useful for other things?
My bash script could be modified for other tag-stripping purposes, as long as the tags you want to keep are consistently labelled.

## I'm no programmer
Note that I'm a newbie to bash scripting so I'm sure my code could be written more efficiently. It works though. :-)

## Requirements and Disclaimer:
* You'll need to have exiftool installed on your computer for the bash script to work (it's free, http://www.sno.phy.queensu.ca/~phil/exiftool/).

* I built this for my own use.

* It is not an official product of iNaturalist.
* Use at your own risk.
