public class TestData 
{
	/** 
	 * Returns a JSON string for a test / sample import
	 **/
	public static String asJSON()
	{
		return 
			'{' +
				'"drivers" : [ ' +
					'{' +
						'"name" : "Lewis Hamilton",' + 
						'"nationality" : "British",' + 
						'"driverId" : "44",' + 
						'"twitterHandle" : "lewistwitter"' +
					'}' +
				'],' +
				'"seasons" : [ ' +
					'{' +
						'"year" : "2013",' +
						'"races" : [' +
							'{' +
								'"round" : 1,' +
								'"name" : "Spain",' +
								'"contestants" : [' +
									'{' +
										'"driverId" : "44",' +
										'"championshipPoints" : 44,' +
										'"dnf" : false,' +
										'"qualification1LapTime" : 123,' + 
										'"qualification2LapTime" : 124,' + 
										'"qualification3LapTime" : 125' + 
									'}' +
								']' +
							'}' +
						']' + 
					'}' +
				']' +
			'}';
	}

	public static void createVolumeDataForViewStateTest()
	{
		// Create a big race!
		List<Driver__c> drivers = new List<Driver__c>();
		for(Integer driverIdx = 0; driverIdx < 50; driverIdx++)
			drivers.add(
				new Driver__c(
					Name = 'Driver #' + driverIdx, 
					DriverId__c = '#' + driverIdx,
					TwitterHandle__c = 'twitter' + driverIdx));

		// Create records
		fflib_SObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Season__c season = new Season__c(Name = 'Volume Test', Year__c = '2015');
		Race__c race = new Race__c(Name = 'Volume Race');
		uow.registerNew(season);
		uow.registerNew(race, Race__c.Season__c, season);
		for(Driver__c driver : drivers)
		{
			uow.registerNew(driver);
			Contestant__c contestant = new Contestant__c();
			uow.registerNew(contestant, Contestant__c.Race__c, race);
			uow.registerRelationship(contestant, Contestant__c.Driver__c, driver);
		}
		uow.commitWork();
	}
}