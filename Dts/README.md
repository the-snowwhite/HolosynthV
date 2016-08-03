Device tree overlays can be loaded via the configfs in kernels v4+, to setup automount
put a line like this in /etc/fstab:

#----------------------------------------------------------#

	/sys/kernel/config /config         none    bind                      0 0

# --------- Example           -----------------------------#

	machinekit@mksocfpga:~$ cat /etc/fstab
	# /etc/fstab: static file system information.
	#
	# <file system>    <mount point>   <type>  <options>       <dump>  <pass>
	/dev/root          /               ext4    noatime,errors=remount-ro 0 1
	tmpfs              /tmp            tmpfs   defaults                  0 0
	none               /dev/shm        tmpfs   rw,nosuid,nodev,noexec    0 0
	/sys/kernel/config /config         none    bind                      0 0

	sudo sh -c 'cat << EOT >/etc/fstab
	# /etc/fstab: static file system information.
	#
	# <file system>    <mount point>   <type>  <options>       <dump>  <pass>
	/dev/root          /               ext4    noatime,errors=remount-ro 0 1
	tmpfs              /tmp            tmpfs   defaults                  0 0
	none               /dev/shm        tmpfs   rw,nosuid,nodev,noexec    0 0
	/sys/kernel/config /config         none    bind                      0 0
	EOT'

#----------------------------------------------------------#
# --------- Current MK hm2-socfpga Overlay Fragment -------#

cat hm2reg_uio.dts


    /dts-v1/ /plugin/;

    / {
       fragment@0 {
          target-path = "/soc/base_fpga_region";
		#address-cells = <1>;
		#size-cells = <1>;
      __overlay__ {
			#address-cells = <1>;
			#size-cells = <1>;

			ranges = <0x00040000 0xff240000 0x00010000>;
			firmware-name = "socfpga/socfpga.rbf";

			uioreg_io_0: uio-socfpga@0x40000 {
				compatible = "htrnic,uioreg-io-1.0";
				reg = <0x40000 0x10000>;
				clocks = <&osc1>;
				address_width = <14>;
				data_width = <32>;
			};
		};
	};
};


the latest wotking version of the device-tree-tools (v1.4.1) can be installed like this:

	sudo apt -y install wget

	wget https://github.com/the-snowwhite/soc-image-buildscripts/raw/4.4-rt/dtc-overlay.sh
	chmod +x dtc-overlay.sh
	./dtc-overlay.sh

Compile the fragment:

	dtc -I dts -O dtb -o hm2reg_uio.dtbo hm2reg_uio.dts
	scp hm2reg_uio.dtbo machinekit@mksocfpga.local:~/

# --------- Overlay command examples -----------------------------#

	ls /config/device-tree/overlays

# status

	cat /config/device-tree/overlays/uio0/status

# manual load

	sudo mkdir /config/device-tree/overlays/uio0
	sudo sh -c 'cat /lib/firmware/mksocfpga/dtbo/hm2reg_uio.dtbo > /config/device-tree/overlays/uio0/dtbo'

# remove and unload driver:

	sudo modprobe -r hm2reg_uio
	sudo rmdir /config/device-tree/overlays/uio0

#----------------------------------------------------------#
# clear logfiles:

	sudo sh -c 'echo ""  >/var/log/linuxcnc.log'
	sudo sh -c 'echo ""  >/home/machinekit/linuxcnc_debug.txt'
	sudo sh -c 'echo ""  >/home/machinekit/linuxcnc_print.txt'


#----------------------------------------------------------#
# list pin assignments (after a short run of machinekit, loadinG hm2_soc_config)

NOTE:   -->  IO Pin 000
Are the correct GPIO0[]  numbers.

#----------------------------------------------------------#


	mib@debian9-ws:~$ ssh -X machinekit@mksocfpga.local
	Debian GNU/Linux 8

	Machinekit Debian Image 2016-04-27

	Support/FAQ: http://www.machinekit.io/

	default username:password is [machinekit:machinekit]

	machinekit@mksocfpga.local's password:

	The programs included with the Debian GNU/Linux system are free software;
	the exact distribution terms for each program are described in the
	individual files in /usr/share/doc/*/copyright.

	Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
	permitted by applicable law.
	Last login: Mon May  2 01:44:22 2016 from debian9-ws.holotronic.lan
	manpath: can't set the locale; make sure $LC_* and $LANG are correct
	environment set up for RIP build in /home/machinekit/machinekit/src
	machinekit@mksocfpga:~$ machinekit
	MACHINEKIT - 0.1
	Machine configuration directory is '/home/machinekit/machinekit/configs/hm2-soc-stepper2'
	Machine configuration file is '5i25-soc.ini'
	Starting Machinekit...
	io started
	halcmd loadusr io started
	task pid=1920
	emcTaskInit: using builtin interpreter
	Shutting down and cleaning up Machinekit...
	Cleanup done
	machinekit@mksocfpga:~$ cat  /var/log/linuxcnc.log

	May  2 01:58:28 mksocfpga msgd:0: startup pid=1881 flavor=rt-preempt rtlevel=1 usrlevel=1 halsize=524288 shm=Posix gcc=4.9.2 version=unknown
	May  2 01:58:28 mksocfpga msgd:0: ØMQ=4.0.5 czmq=3.0.2 protobuf=2.6.1 libwebsockets=<no version symbol>
	May  2 01:58:28 mksocfpga msgd:0: configured: sha=a46f4b9
	May  2 01:58:28 mksocfpga msgd:0: built:      May  1 2016 22:00:04 sha=a46f4b9
	May  2 01:58:28 mksocfpga msgd:0: register_stuff: actual hostname as announced by avahi='mksocfpga.local'
	May  2 01:58:28 mksocfpga msgd:0: zeroconf: registering: 'Log service on mksocfpga.local pid 1881'
	May  2 01:58:29 mksocfpga msgd:0: rtapi_app:1887:user accepting commands at ipc:///tmp/0.rtapi.a42c8c6b-4025-4f83-ba28-dad21114744a
	May  2 01:58:29 mksocfpga msgd:0: zeroconf: registered 'Log service on mksocfpga.local pid 1881' _machinekit._tcp 0 TXT "uuid=a42c8c6b-4025-4f83-ba28-dad21114744a" "instance=5d4161d6-1009-11e6-9a82-823af0754b95" "service=log" "dsn=ipc:///tmp/0.log.a42c8c6b-4025-4f83-ba28-dad21114744a"
	May  2 01:58:29 mksocfpga msgd:0: hal_lib:1887:rt hm2: loading Mesa HostMot2 driver version 0.15
	May  2 01:58:29 mksocfpga msgd:0: hal_lib:1887:rt hm2_soc: loading Mesa AnyIO HostMot2 socfpga driver version 0.8
	May  2 01:58:29 mksocfpga msgd:0: hal_lib:1887:rt hm2_soc: device tree overlay node: /config/device-tree/overlays/uio0 not found ...  will create it
	May  2 01:58:29 mksocfpga msgd:0: hal_lib:1887:rt hm2_soc: hm2reg_uio loaded ... will now mmap after a small delay
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0: 34 I/O Pins used:
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 000 (Wrong-01): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 001 (Wrong-14): PWMGen #0, pin Out0 (PWM or Up) (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 002 (Wrong-02): StepGen #0, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 003 (Wrong-15): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 004 (Wrong-03): StepGen #0, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 005 (Wrong-16): StepGen #4, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 006 (Wrong-04): StepGen #1, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 007 (Wrong-17): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 008 (Wrong-05): StepGen #1, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 009 (Wrong-06): StepGen #2, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 010 (Wrong-07): StepGen #2, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 011 (Wrong-08): StepGen #3, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 012 (Wrong-09): StepGen #3, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 013 (Wrong-10): Encoder #0, pin A (Input)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 014 (Wrong-11): Encoder #0, pin B (Input)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 015 (Wrong-12): Encoder #0, pin Index (Input)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 016 (Wrong-13): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 017 (Wrong-01): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 018 (Wrong-14): PWMGen #1, pin Out0 (PWM or Up) (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 019 (Wrong-02): StepGen #5, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 020 (Wrong-15): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 021 (Wrong-03): StepGen #5, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 022 (Wrong-16): StepGen #9, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 023 (Wrong-04): StepGen #6, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 024 (Wrong-17): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 025 (Wrong-05): StepGen #6, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 026 (Wrong-06): StepGen #7, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 027 (Wrong-07): StepGen #7, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 028 (Wrong-08): StepGen #8, pin Step (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 029 (Wrong-09): StepGen #8, pin Direction (Output)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 030 (Wrong-10): Encoder #1, pin A (Input)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 031 (Wrong-11): Encoder #1, pin B (Input)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 032 (Wrong-12): Encoder #1, pin Index (Input)
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0:     IO Pin 033 (Wrong-13): IOPort
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0: registered
	May  2 01:58:34 mksocfpga msgd:0: hal_lib:1887:rt hm2_soc: initialized AnyIO hm2_soc_board
	May  2 01:59:06 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0: requested watchdog timeout is out of range, setting it to max: 4294967295 ns
	May  2 01:59:06 mksocfpga msgd:0: hal_lib:1887:rt hm2/hm2_5i25.0: unregistered
	May  2 01:59:06 mksocfpga msgd:0: hal_lib:1887:rt hm2_soc: UIO driver unloaded
	May  2 01:59:06 mksocfpga msgd:0: hal_lib:1887:rt hm2: unloading
	May  2 01:59:08 mksocfpga rtapi:0: unload: 'trivkins' not loaded
	May  2 01:59:08 mksocfpga rtapi:0: unload: 'tp' not loaded
	May  2 01:59:08 mksocfpga rtapi:0: unload: 'hostmot2' not loaded
	May  2 01:59:08 mksocfpga rtapi:0: unload: 'hm2_soc' not loaded
	May  2 01:59:08 mksocfpga rtapi:0: unload: 'motmod' not loaded
	May  2 01:59:09 mksocfpga msgd:0: rtapi_app exit detected - scheduled shutdown
	May  2 01:59:11 mksocfpga msgd:0: msgd shutting down
	May  2 01:59:11 mksocfpga msgd:0: zeroconf: unregistering 'Log service on mksocfpga.local pid 1881'
	May  2 01:59:11 mksocfpga msgd:0: log buffer hwm: 0% (37 msgs, 3964 bytes out of 524288)
	May  2 01:59:11 mksocfpga msgd:0: normal shutdown - global segment detached
	machinekit@mksocfpga:~$
