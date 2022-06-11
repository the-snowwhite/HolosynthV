file copy -force holosynthv_wrapper.bit /tftpboot/system.bit
# exec aplay -L
#exec aplay -q -D plughw:CARD=StudioLive,DEV=0 /home/vivado/ding.wav
exec aplay -q -D plughw:CARD=HDMI,DEV=9 /home/vivado/ding.wav
