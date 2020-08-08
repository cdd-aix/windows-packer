# Mooched from https://github.com/rgl/windows-vagrant
MAKEFLAGS += --no-buildin-rules
MAKEFLAGS += --no-builtin-variables
IMAGES += windows-2019

# Revisit as a pattern
windows-2019-amd64-virtualbox.ovf: windows-2019.json
	rm -f "$@"
	packer build --only=$(basename $@) --on-error=abort --force --timestamp-ui $<

%.json: %.yaml
	yq read --tojson --prettyPrint --indent 4 $< > "$@"

# %-amd64-virtualbox.ovf: %.json windows-vagrant/%/autounattend.xml
# 	rm -f "$@"
# 	CHECKPOINT_DISABLE=1 PACKAGE_LOG=1 PACKER_LOG_PATH="$@.log" \
# 		packer build --only=$*-amd64-virtualbox -on-error=abort $<
