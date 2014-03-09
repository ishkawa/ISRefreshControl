test:
	xcodebuild clean test \
		-sdk iphonesimulator \
		-workspace ISRefreshControl.xcworkspace \
		-scheme ISRefreshControl \
		-configuration Debug \
		-destination "name=iPhone Retina (4-inch),OS=7.0" \
		OBJROOT=build \
		GCC_PREPROCESSOR_DEFINITIONS="IS_TEST_FROM_COMMAND_LINE=1"

