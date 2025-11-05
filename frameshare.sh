#!/bin/bash
#####################################
VERSION="0.1"
NAME="FrameShare"
AUTHOR="RadicalEd"
DESCRIPTION="Convert a set of Images to a Sharable Video Archive, and Vice Versa"
LICENSE=""
#####################################
# Requirements

REQUIREMENTS=(ffmpeg:ffmpeg convert:imagemagick)

WIDTH=1920
HEIGHT=1080
FPS=10
SEED="$(date +%s)"

# End of Requirements
#####################################
# Colors

c () {
	case "${1}" in
		(black)      tput setaf 0;;
		(red)        tput setaf 1;;
		(green)      tput setaf 2;;
		(yellow)     tput setaf 3;;
		(blue)       tput setaf 4;;
		(magenta)    tput setaf 5;;
		(cyan)       tput setaf 6;;
		(white)      tput setaf 7;;
		(bg_black)   tput setab 0;;
		(bg_red)     tput setab 1;;
		(bg_green)   tput setab 2;;
		(bg_yellow)  tput setab 3;;
		(bg_blue)    tput setab 4;;
		(bg_magenta) tput setab 5;;
		(bg_cyan)    tput setab 6;;
		(bg_white)   tput setab 7;;
		(n)          tput sgr0;;
	esac
}

# End of Colors
#####################################
# Banner

BANNER="$(cat << 'EOF'
888888 88""Yb    db    8b    d8 888888 .dP"Y8 88  88    db    88""Yb 888888 
88__   88__dP   dPYb   88b  d88 88__   `Ybo." 88  88   dPYb   88__dP 88__   
88""   88"Yb   dP__Yb  88YbdP88 88""   o.`Y8b 888888  dP__Yb  88"Yb  88""   
88     88  Yb dP""""Yb 88 YY 88 888888 8bodP' 88  88 dP""""Yb 88  Yb 888888 
EOF
)"

banner () {
	echo "$(c cyan)$BANNER$(c n)" >&2
	echo >&2
}

# End of Banner
#####################################
# Usage

PROGRAM=$0
TCOLS="$(tput cols)"
HIGHLIGHT="blue"

usage () {
banner
cat << EOF >&2
$(c $HIGHLIGHT)$NAME$(c n) v$VERSION - Written By $(c $HIGHLIGHT)$AUTHOR$(c n)

$(echo -n "	$DESCRIPTION" | fmt -w $TCOLS)

$(c $HIGHLIGHT)USAGE$(c n): $PROGRAM [-h] [-e] [-f fps] [-W width] [-H height] <FILES..>

	-h       : show usage
	-e       : extract the frames from a video file
	-s       : use pixel scrambling algorithm
	-S <num> : numerical seed to use when scrambling
	-W <num> : max width (default: 1920)
	-H <num> : max height (default: 1080)
	-f <num> : fps when creating videos (default: 3)

EOF
}

error () {
	code="$1";shift
	case "$code" in
		(1) usage;;
	esac
	echo "Error $code: $*" >&2
	exit "$code"
}

statusline () {
	echo -e -n "\r$*"
}

say () {
	echo "$*" >&2
}


# End of Usage
#####################################
# Arguments

while getopts "hesS:W:H:f:" o;do
	case "${o}" in
		(h) usage && exit;;
		(e) EXTRACT="true";;
		(s) SCRAMBLE="true";;
		(S) SCRAMBLE="true";SEED="$OPTARG";;
		(W) WIDTH="$OPTARG";;
		(H) HEIGHT="$OPTARG";;
		(f) FPS="$OPTARG";;
		(*) echo "$PROGRAM -h for Help" >&2 && exit 1;;
	esac
done

shift $((OPTIND-1))

[ ! "$1" ] && error 1 "We Need Atleast One File"

# End of Arguments
#####################################
# Execution

banner

[ "$SCRAMBLE" ] && say "$(c yellow)Warning$(c n): There is a loss of both quality, and colors, when scrambling." && say ""

tmpdir='/tmp/frameshare'
mkdir "$tmpdir"

if [ "$EXTRACT" ];then


	# Extract Frames From Video
	video="$1"
	outdir="extracted_frames_$(date +%s)"
	mkdir "$outdir"
	if [ "$SCRAMBLE" ];then
		echo "Descrambling Frames With Seed: $(c green)$SEED$(c n)" >&2
		ffmpeg -i "$video" -vf "shufflepixels=d=inverse:m=block:w=1:h=1:seed=$SEED" "$outdir/image_%04d.png" 2> /dev/null 1> /dev/null
	else
		echo "Extracting Frames..." >&2
		ffmpeg -i "$video" "$outdir/image_%04d.png" 2> /dev/null 1> /dev/null
	fi
	echo "Finished. Have a nice day." >&2


else


	# Convert Image Files Into Compatible Frames
	index=0
	for file in $*;do
		index=$((index+1))
		statusline "Preparing Frames... ($index/$#)"
		convert "$file" -resize "${WIDTH}x${HEIGHT}" -background black -gravity center -extent "${WIDTH}x${HEIGHT}" "$tmpdir/frame_$(printf "%04d" "$index").png"
	done
	echo # close statusline


	# Create Video From Frames
	vidname="video-$(date +%s)-${SEED}.mp4"
	say "Creating Video..."
	if [ "$SCRAMBLE" ];then
		ffmpeg -r $FPS -i $tmpdir/frame_%04d.png -vf "shufflepixels=d=forward:m=block:w=1:h=1:seed=$SEED" -vcodec libx264 -movflags faststart -pix_fmt yuva420p "$vidname" 2> /dev/null 1> /dev/null
		say "Your Scrambling Seed is: $(c green)$SEED$(c n)"
		say "It Will Be Needed When Descrambling."
	else
		ffmpeg -r $FPS -i $tmpdir/frame_%04d.png -vcodec libx264 -movflags faststart -pix_fmt yuva420p "$(date +%s).mp4" 2> /dev/null 1> /dev/null
	fi
	echo "$vidname"
fi

rm -rf "$tmpdir"

# End of Execution
#####################################
