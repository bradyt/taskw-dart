vendor:
	bundle install

stable: vendor
	cd ..; flutter build ios --no-codesign --flavor stable
	bundle exec fastlane gym --scheme stable

beta: vendor
	cd ..; flutter build ios --no-codesign --flavor beta
	bundle exec fastlane gym --scheme beta

upload:
	bundle exec fastlane pilot upload \
		--skip_submission \
		--skip_waiting_for_build_processing
