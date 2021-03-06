#include <linux/init.h>
#include <linux/module.h>
/* prototypes */
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
/* timeout */
#include <linux/sched.h>
/* semaphore */
#include <linux/semaphore.h>


#define DRIVER_NAME "lock"

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

static int major;
static struct file_operations fobs;
static dev_t dev_number;
static struct cdev *driver_object;
struct class *lock_class;

/* semaphore */
static struct semaphore sema;
static DEFINE_SEMAPHORE(sema);

static int driver_open(struct inode *geraetedatei, struct file *instanz)
{
	/* try to get access */
	while( down_trylock( &sema ) != 0 ) {
		printk("LOCK: busy...\n");
		/* wait 200 mili seconds */
		schedule_timeout_interruptible( 200*HZ/1000 );
		if( signal_pending(current) ) {
			/* leave critical section */
			up(&sema);
			return -EIO;
		}
	}
	printk("LOCK: sleeping 3 seconds -> start\n");
	/* sleep for 3 seconds */
	schedule_timeout_interruptible( 3*HZ );
	printk("LOCK: sleeping 3 seconds -> finish\n");
	/* leave critical section */
	up(&sema);
	return EXIT_SUCCESS;
}

static ssize_t driver_read(struct file *instanz, char *user, size_t count, loff_t *offset)
{
	printk(KERN_INFO "LOCK: read called...\n");
	return 0;
}

static struct file_operations fobs =
{
	.owner = THIS_MODULE,
	.open = driver_open,
	.read = driver_read
};

static int __init ModInit(void)
{
	/* reserve device driver number */
	if(alloc_chrdev_region(&dev_number, 0, 1, DRIVER_NAME) < 0)
	{
		printk("failed to alloc_chrdev_region\n");	
		return -EIO;
	}
	/* reserve object */
	driver_object = cdev_alloc();
	
	if(driver_object == NULL)
	{
		goto free_device_number;
	}
	driver_object->owner = THIS_MODULE;
	driver_object->ops = &fobs;
	
	if(cdev_add(driver_object, dev_number, 1))
	{
		goto free_cdev;
	}
	
	lock_class = class_create(THIS_MODULE, DRIVER_NAME);
	device_create(lock_class, NULL, dev_number, NULL, "%s", DRIVER_NAME);
	
	major = MAJOR(dev_number);
	
	printk("Major number: %d\n", major);
	return EXIT_SUCCESS;
	
free_cdev:
	kobject_put(&driver_object->kobj);
	
free_device_number:
	unregister_chrdev_region(dev_number, 1);
	return -EIO;
	
}

static void __exit ModExit(void) 
{
	device_destroy(lock_class, dev_number);
	class_destroy(lock_class);
	cdev_del(driver_object);
	unregister_chrdev_region(dev_number, 1);
	return;
}

module_init(ModInit);
module_exit(ModExit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Timotheus Ruprecht and  Steffen Gorenflo");
MODULE_DESCRIPTION("Modul Lock");
MODULE_SUPPORTED_DEVICE("none");


