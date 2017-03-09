# iNaturalist_cull_photo_tags
iNaturalist (http://inaturalist.org) is a great place to post nature observations. Its photo upload tool imports all the tags in photos, unless you manually edit them out during upload. That is tedious when bulk uploading lots of photos. To save time, this bash script strips all the tags from my photos except my iNaturalist tags.

I only want a subset of my tags included in my uploads (e.g., I don't want people's names shared, or all the EOL higher taxonomy tags I add to my photos). This bash script uses takes a folder of jpg images and uses exiftool to remove all tags  except the tags I want to go to iNaturalist.

My workflow is to upload my photos to Darktable (http://www.darktable.org/), geotag those images without locations using a GPX file (made using the Cyclemeter app on my iPhone), add lots of tags to my photos, export those photos I want to send to iNaturalist to one folder, then run this bash script in the Terminal app on my Mac to strip out all the tags except those starting with "iNaturalist field|", "iNaturalist tag|", "Species|", and "Places|".

This script could be modified for other purposes, as long as the tags you want to keep are consistently labelled.

Note that I'm a newbie to bash scripting so I'm sure the code could be written more efficiently. It works though.
