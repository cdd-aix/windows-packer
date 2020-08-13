# Mooched from https://github.com/rgl/windows-vagrant
MAKEFLAGS += --no-buildin-rules
MAKEFLAGS += --no-builtin-variables
IMAGES += windows-2019
# TODO: Examine the cleanup provisioner
PACKER_ON_ERROR ?= cleanup
# TODO: Explore force behavior
# PACKER_BUILD_ARGS ?= --force
export RGLDIR = windows-vagrant
RGLURL = https://github.com/rgl/windows-vagrant.git


# This enables the template rule have all targets here
# windows-10-amd64-virtualbox.ova: %-virtualbox.ova: # output-%-virtualbox/packer-%.ova
# 	echo @ $@ f $^

# Rough naming conventon
# windows-version-type[-layer].ova
windows-2019-%.ova: export ISO_URL = https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso
windows-2019-%.ova: export UNATTENDED = $(RGLDIR)/tmp/windows-2019-vsphere/autounattend.xml
windows-%.ova: export PACKER_TEMPLATE = windows.json
%.ova: export ISO_CHECKSUM ?= none
%.ova: export MEMORY ?= 8192
%.ova: export GUEST_OS_TYPE ?= Windows2019_64
%.ova: export SETUPWINRM ?= $(RGLDIR)/winrm.ps1
%.ova:
	@echo $@, $^
	$(MAKE) runpacker

runpacker: $(PACKER_TEMPLATE) $(SETUPWINRM) $(UNATTENDED)
	@echo $@, $^
	echo $(RGLDIR) $(SETUPWINRM) $(UNATTENDED)
	packer validate $<
	packer build --force $<

.PHONY: runpacker

# Revisit as a pattern
windows-2019-nvm-amd64-virtualbox.ova: windows-2019-nvm.json windows-2019-amd64-virtualbox.ova
	packer validate $<
	rm -vf "$@"
	packer build --only=$(basename $@) --on-error=$(PACKER_ON_ERROR) $(PACKER_BUILD_ARGS) --timestamp-ui $<
	mv -v output-$(basename $@)/packer-$(basename $@)-*.ova $@
	rmdir -v output-$(basename $@)

# Perhaps an iso and an ovf stem and _ to separate stem from name
windows-2019-amd64-virtualbox.ova: windows-2019.json $(RGLDIR)/windows-2019/autounattend.xml
	packer validate $<
	rm -vf $@
	packer build --only=$(basename $@) --on-error=$(PACKER_ON_ERROR) $(PACKER_BUILD_ARGS) --timestamp-ui $<
	mv -v output-$(basename $@)/packer-$(basename $@)-*.ova $@
	rmdir -v output-$(basename $@)

%.json: %.yaml
	yq read --tojson --prettyPrint --indent 4 $< > "$@"

$(RGLDIR)/tmp/%-vsphere/autounattend.xml: $(RGLDIR)/%/autounattend.xml
	make -C $(RGLDIR) tmp/$*-vsphere/autounattend.xml

$(RGLDIR)/%: $(RGLDIR)
	test -r "$@"

$(RGLDIR):
	git clone $(RGLURL) $(RGLDIR)


# %-amd64-virtualbox.ovf: %.json windows-vagrant/%/autounattend.xml
# 	rm -f "$@"
# 	CHECKPOINT_DISABLE=1 PACKAGE_LOG=1 PACKER_LOG_PATH="$@.log" \
# 		packer build --only=$*-amd64-virtualbox -on-error=abort $<
