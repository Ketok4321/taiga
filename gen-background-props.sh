#!/usr/bin/bash

rm -rf gnome-background-properties && mkdir gnome-background-properties

for b in backgrounds/* ; do
	b=$(basename $b)
	sed "s/FILENAME/$b/g" prop-template.xml > gnome-background-properties/$b.xml
done
