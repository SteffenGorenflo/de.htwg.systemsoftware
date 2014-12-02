##### ZERO

ZERO_VERSION = 1.0
ZERO_SITE_METHOD = file
ZERO_SITE = zero-$(ZERO_VERSION).tar.gz


TEMPLATE_DEPENDENCIES = linux

define TEMPLATE_BUILD_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules 
endef

define TEMPLATE_INSTALL_TARGET_CMDS
	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules_install
endef

define TEMPLATE_CLEAN_CMDS
	$(MAKE) -C $(@D) clean
endef

define TEMPLATE_UNINSTALL_TARGET_CMS
	rm $(TARGET_DIR)/usr/bin/zero
endef

$(eval $(generic-package))
