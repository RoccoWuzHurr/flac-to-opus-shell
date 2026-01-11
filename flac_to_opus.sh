# name: flac to opus mass converter
# author: roccowuzhurr
# created: 1/10/26
# last updated: 1/10/26
# description: shell script that converts flac files into opus files, to save storage while keeping audio quality above mp3 levels. made primarily because i didn't trust any tools for android and decided i'd rather write the thing myself. didn't want to manually convert all the files using ffmpeg either, and wanted to make sure my tags stayed correct. this is my first shell script, so any inconsistencies are due to the fact that i learned how to do this by making this. 

menu=0 # lets menu loop until satisfied, reused multiple times for simplicity
first=0 # for "confirm for only first file" option, turns 1 after first file is converted
confirm=0 # for "confirm for all files" option, turns 1 when true
user_bitrate_override=128000 # value for bitrate override, defaulted to 128kb/s
user_override=0 # toggle for bitrate override


while [ $menu -eq 0 ]; do # options
	printf "\nMass .flac to .opus converter script\nvers 1.0\nrequires ffmpeg\n\n1 - use default bitrates\n2 - use custom bitrates\n3 - exit\n\n>"
	read -n1 opt

	if [ $opt -eq 1  ]; then # default case
		menu=1 # default state; nothing needs to change
	elif [ $opt = 2 ]; then # custom bitrate case
		while [ $menu -eq 0 ]; do
			menu=1 # TODO: FINISH CUSTOM BITRATE 
		done
	elif [ $opt -eq 3 ]; then # exit case
		printf "\n"
		exit
	fi
done

menu=0

while [ $menu = "0" ]; do
        printf  "\n\n1 - Confirm for only first file\n2 - Confirm for all files\n3 - Confirm for no files\n\n>"	
	read -n1 opt
	
	if [ $opt = "1" ]; then
		menu=1 # default state; no variables need to change here
	elif [ $opt = "2" ]; then
		menu=1
		first=1 # don't need to prompt with the first file specific text if confirming all files
		confirm=1
	elif [ $opt = "3" ]; then
		menu=1 
		first=1 # skips first file prompt
	fi
	echo
done

for d in *; do # checks in directions, added this way later in and did NOT feel like changing the indentation of the whole thing
if [ -d "$d" ]; then # makes sure it only tries to find songs inside of a directory, not trying to look for files inside a file in the root

#if [ -f "$d/*.flac" ]; then # makes sure theres at least one .flac, it'll error out next line if not
	#echo "blehh" # it doesn't seem like this part is needed; if theres some weird error i'll try to fix it
for i in "$d"/*.flac; do # Main loop
	
	proc_name=${i%.*c}".opus"
	bitrate="128000" # default value just incase

# to feel a little better3 about compression's quality loss, I'll change the bitrate set depending on the amount of audio channels, 
# to the values set by xiph.org
# should probably go fine, and realistically it wouldn't be noticable if it was always at 96kb/s, for 99% of people.
	
	channels=$(ffprobe -i "$i" -show_entries stream=channels -select_streams a:0 -of compact=p=0:nk=1 -v 0 -loglevel quiet;)
	channels="${channels%|}"
	
	if [ $first = 0 ]; then # allows user to be sure they're configuring the right files
		printf "\n\nTo confirm, the first file you will be editing is: '$i', \nturning it into '$proc_name', \nwith a bitrate of $bitrate bp/s.\nPress any key to continue.\nPress 'x' to exit if this doesn't seem right.\n\n>"
		read -n1 x
		if [ $x = "x" ]; then
		       echo
		       exit
		fi
 		first=1	
	elif [ $confirm -eq 1 ]; then
		printf "\nEditing '$i', \ninto '$proc_name' \nwith a bitrate of $bitrate bp/s.\nPress any key to continue.\nPress'x' to exit.\n>"
		read -n1 x
		if [ $x = "x" ]; then
			echo
			exit
		fi
	fi

	
	printf "\nConverting '${i%.*c}'...\n"
	
	if [ $user_override -eq 1 ]; then
		printf "Bitrate set to $user_bitrate_override"
		bitrate=$user_bitrate_override;
	elif [ $channels -lt 6 ]; then
		printf "Song has less than 6 channels. Setting bitrate to 128kb/s, probably transparent :)\n"
		bitrate="128000"
	elif [ $channels -lt 8 ]; then
		printf "Song has more than 6 channels, but less than 8. Setting bitrate to 256kb/s, probably transparent:)\n"
		bitrate="256000"
	elif [ $channels -ge 8 ]; then
		printf "Song has 8 or more channels. Setting bitrate to 450kb/s. This file might be large, override to 256kb/s or higher if too large.\n"
		bitrate="450000"
	fi


	ffmpeg -i "$i" -acodec libopus -b:a $bitrate "$proc_name" -loglevel quiet
done
fi
printf "\n\n Thank you!! Have a nice day :D\n"
#fi
done
