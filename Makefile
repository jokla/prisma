PROFILE ?= content/profiles/default.yaml

.PHONY: dev build cv clean

dev:                             ## Start Astro dev server
	cd site && npm run dev

cv:                              ## Generate CV PDF from a profile
	mkdir -p .build outputs
	node scripts/resolve-profile.js --profile $(PROFILE) --out .build/resolved.json
	typst compile --root $(CURDIR) --input data=$(abspath .build/resolved.json) \
	  cv/template.typ outputs/$(notdir $(basename $(PROFILE))).pdf

build: cv                        ## Full production build (CV + site)
	node scripts/copy-default-cv.js
	cd site && npm run build

clean:
	rm -rf .build/ outputs/ site/dist/
