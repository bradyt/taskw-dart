vendor:
	bundle install

build:
	cd ..; flutter build appbundle

validate: vendor
	bundle exec fastlane run validate_play_store_json_key

upload: vendor
	bundle exec fastlane run supply \
		track:"internal" \
		package_name:"info.tangential.task" \
		aab:"../build/app/outputs/bundle/release/app-release.aab" \
		skip_upload_aab:"false" \
		skip_upload_apk:"true" \
		skip_upload_changelogs:"true" \
		skip_upload_images:"true" \
		skip_upload_metadata:"true" \
		skip_upload_screenshots:"true" \
