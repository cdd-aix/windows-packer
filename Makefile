# Mooched from https://github.com/rgl/windows-vagrant
MAKEFLAGS += --no-buildin-rules
MAKEFLAGS += --no-builtin-variables
IMAGES += windows-2019

VIRTUALBOX_BUILDS = $(addsuffix -virtualbox,$(addprefix build-,$(IMAGES)))

.PHONY: help $(VIRTUALBOX_BUILDS)

test: build-windows-2019-virtualbox

help:
	@echo $(IMAGES)
	@$(addprefix echo make ,$(addsuffix ;,$(VIRTUALBOX_BUILDS)))

$(VIRTUALBOX_BUILDS): build-%-virtualbox: .copy-rgl | %-amd64-virtualbox.ovf
%-amd64-virtualbox.ovf: %.json windows-vagrant/%/autounattend.xml
	rm -f "$@"
	CHECKPOINT_DISABLE=1 PACKAGE_LOG=1 PACKER_LOG_PATH="$@.log" \
		packer build --only=$*-amd64-virtualbox -on-error=abort $<

.copy-rgl: windows-vagrant/.git
	touch "$@"

windows-vagrant/.git:
	GIR_WORK_TREE=$(@D) git pull ||	git clone https://github.com/rgl/$(@D)
