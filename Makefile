update_metadata: MetaDataPlistCreator/createPlistFromHeader
	@echo "creating plist file..."
	mv libPhoneNumber/NBGeneratedPhoneNumberMetaData.h MetaDataPlistCreator
	(cd MetaDataPlistCreator && createPlistFromHeader)
	mv MetaDataPlistCreator/phoneNumberMap.plist libPhoneNumber
	rm MetaDataPlistCreator/NBGeneratedPhoneNumberMetaData.h
		
MetaDataPlistCreator/createPlistFromHeader: libPhoneNumber/NBGeneratedPhoneNumberMetaData.h
	@echo "creating binary..."
	cp libPhoneNumber/NBGeneratedPhoneNumberMetaData.h MetaDataPlistCreator
	xcodebuild -target MetaDataPlistCreator
	mv build/Release/createPlistFromHeader MetaDataPlistCreator

libPhoneNumber/NBGeneratedPhoneNumberMetaData.h:
	@echo "creating temporary header file..."
	cd libPhoneNumberTests && ./metadataGenerator
	cd libPhoneNumber && ./GeneratePhoneNumberHeader.sh

clean:
	@echo "deleting all temporary files..."
	rm -f libPhoneNumber/NBGeneratedPhoneNumberMetaData.h
	rm -f libPhoneNumber/phoneNumberMap.plist
	rm -f MetaDataPlistCreator/NBGeneratedPhoneNumberMetaData.h
	rm -f MetaDataPlistCreator/phoneNumberMap.plist
	rm -f MetaDataPlistCreator/createPlistFromHeader
	rm -rf build
