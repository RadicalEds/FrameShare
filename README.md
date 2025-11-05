# FrameShare v0.1

Image Sharing Via Video Frames   
A small utility that packs images into a video file and vice versa, frame by frame   
Has an option to Obfuscate the Images by "Scrambling" their Pixels with a Numerical Seed   

## Requirements

- ffmpeg
- imagemagick

## Screenshots

![Help Menu](https://media.discordapp.net/attachments/1434270963977031690/1435737989362749631/2025-11-05_14-30-12.png?ex=690d0eb3&is=690bbd33&hm=d145b53a5bddfb58c6eb33f5d72d8d3a6d4fdc71cf15f5fbdb923b85e2d3e02a&=&format=webp&quality=lossless)

![Archiving Frames With Scrambling Enabled](https://media.discordapp.net/attachments/1434270963977031690/1435737989794758726/2025-11-05_15-08-38.png?ex=690d0eb3&is=690bbd33&hm=6d1ed8c68111ed5e1a75c58491944eaeba2dd31efb35c347c4cd5553f39647ed&=&format=webp&quality=lossless)

![Extracting A Scrambled Frame Archive](https://media.discordapp.net/attachments/1434270963977031690/1435737988662296596/2025-11-05_14-54-03.png?ex=690d0eb3&is=690bbd33&hm=645aa449da852d29dd5b0c003f14d0fc85dcb549f39f02e4bfbebfe4a49f51b6&=&format=webp&quality=lossless)

## Examples

to Archive all Jpg Images into a Video File 
```./frameshare.sh *.jpg```

to Scramble them as Well
```./frameshare.sh -s *.jpg```

to Extract all Frames from a Video File
```./frameshare.sh -e video.mp4```

to Extract and Unscramble Frames  
```./frameshare.sh -e -S <SEED> video.mp4```

