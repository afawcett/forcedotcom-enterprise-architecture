@isTest
private class ContestantControllerTest 
{	
	@isTest static void testAwardPoints()
	{
		SeasonService.importSeasons(TestData.SEASONSDATA);
		new ContestantController(
			new ApexPages.StandardController(
				[select Id from Contestant__c LIMIT 1])).awardPoints();
	}
}