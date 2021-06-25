onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib holosynthv_opt

do {wave.do}

view wave
view structure
view signals

do {holosynthv.udo}

run -all

quit -force
