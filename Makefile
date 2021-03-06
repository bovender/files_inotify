app_name=files_inotify
project_dir=$(CURDIR)/../$(app_name)
build_dir=$(CURDIR)/build/artifacts
vendor_dir=$(CURDIR)/vendor
sign_dir=$(build_dir)/sign
cert_dir=$(HOME)/.nextcloud/certificates

all: appstore

clean:
	rm -rf $(build_dir) $(vendor_dir)

node_modules: package.json
	npm install

CHANGELOG.md: node_modules
	node_modules/.bin/changelog

appstore: clean CHANGELOG.md
	mkdir -p $(sign_dir)
	rsync -a \
	--exclude=.git \
	--exclude=build \
	--exclude=.gitignore \
	--exclude=Makefile \
	--exclude=screenshots \
	--exclude=phpunit*xml \
	--exclude=node_modules \
	$(project_dir) $(sign_dir)
	tar -czf $(build_dir)/$(app_name).tar.gz \
		-C $(sign_dir) $(app_name)
	openssl dgst -sha512 -sign $(cert_dir)/$(app_name).key $(build_dir)/$(app_name).tar.gz | openssl base64
