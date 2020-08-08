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

# Revisit as a pattern
windows-2019-amd64-virtualbox.ovf: windows-2019.json $(RGLDIR)/windows-2019/autounattend.xml
	packer validate $<
	rm -vf $@
	packer build --only=$(basename $@) --on-error=$(PACKER_ON_ERROR) $(PACKER_BUILD_ARGS) --timestamp-ui $<

%.json: %.yaml
	yq read --tojson --prettyPrint --indent 4 $< > "$@"


$(RGLDIR)/%:
	git clone $(RGLURL) $(RGLDIR)


# %-amd64-virtualbox.ovf: %.json windows-vagrant/%/autounattend.xml
# 	rm -f "$@"
# 	CHECKPOINT_DISABLE=1 PACKAGE_LOG=1 PACKER_LOG_PATH="$@.log" \
# 		packer build --only=$*-amd64-virtualbox -on-error=abort $<
