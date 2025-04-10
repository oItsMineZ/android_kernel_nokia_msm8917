ifeq ($(CONFIG_OF),y)

#used for cleaning - not building
subdir- := qcom
endif

dtbs: $(addprefix $(obj)/, $(DTB_LIST))
	$(Q)rm -f $(obj)/../*.dtb

clean-files := *.dtb
dtbs_install: $(addsuffix _dtbinst_, $(dtb-y))
