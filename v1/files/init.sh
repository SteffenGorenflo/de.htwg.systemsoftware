#!/bin/busybox sh 

# Say Hello
echo '######################'
echo 'Starting system'
echo '######################'


/bin/busybox --install -s /bin/

#mount
echo '--> Mounting...'
mount -t proc proc /proc
mount -t sysfs none /sys
mount -t tmpfs none /tmp
echo '--> done'

echo 0 > /proc/sys/kernel/printk

#start init program and display system infos
echo '--> start binary'
./bin/systeminfo


#end
echo '--> Starting shell'
setsid cttyhack sh
