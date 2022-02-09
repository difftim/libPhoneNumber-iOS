update_metadata:
	(cd libPhoneNumberTests && ./metadataGenerator) && \
		(cd libPhoneNumber && ./GeneratePhoneNumberHeader.sh) && \
		(cp libPhoneNumber/NBGeneratedPhoneNumberMetaData.h MetaDataPlistCreator) && \
		(cd MetaDataPlistCreator && MetaDataPlistCreator) && \
		(cp MetaDataPlistCreator/phoneNumberMap.plist libPhoneNumber) &&\
		(rm MetaDataPlistCreator/phoneNumberMap.plist) &&\
		(rm libPhoneNumber/NBGeneratedPhoneNumberMetaData.h)
