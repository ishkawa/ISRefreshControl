test:
	xcodebuild \
		-sdk iphonesimulator \
		-workspace ISRefreshControl.xcworkspace \
		-scheme ISRefreshControlTests \
		-configuration Debug \
		clean build \
		ONLY_ACTIVE_ARCH=NO \
		TEST_AFTER_BUILD=YES \
		GCC_PREPROCESSOR_DEFINITIONS="IS_TEST_FROM_COMMAND_LINE=1" \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

