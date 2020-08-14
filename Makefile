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


windows-2019-vs2015-amd64-virtualbox.ova: windows-2019-vs2015.json windows-2019-nvm-amd64-virtualbox.ova
	packer validate $<
	rm -rvf output-$(basename $@)
	rm -vf "$@"
	packer build --only=$(basename $@) --on-error=$(PACKER_ON_ERROR) $(PACKER_BUILD_ARGS) --timestamp-ui $<
	mv -v output-$(basename $@)/packer-$(basename $@)-*.ova $@
	rmdir -v output-$(basename $@)
# windows-2019-vs2017-amd64-virtualbox.ova: windows-2019-vs2017.json windows-2019-nvm-amd64-virtualbox.ova
# 	packer validate $<
# 	rm -rvf output-$(basename $@)
# 	rm -vf "$@"
# 	packer build --only=$(basename $@) --on-error=$(PACKER_ON_ERROR) $(PACKER_BUILD_ARGS) --timestamp-ui $<
# 	mv -v output-$(basename $@)/packer-$(basename $@)-*.ova $@
# 	rmdir -v output-$(basename $@)
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


$(RGLDIR)/%:
	git clone $(RGLURL) $(RGLDIR)


# %-amd64-virtualbox.ovf: %.json windows-vagrant/%/autounattend.xml
# 	rm -f "$@"
# 	CHECKPOINT_DISABLE=1 PACKAGE_LOG=1 PACKER_LOG_PATH="$@.log" \
# 		packer build --only=$*-amd64-virtualbox -on-error=abort $<
