@isTest
private class RaceServiceTest 
{	
	@isTest static void testAwardPoints()
	{
		SeasonService.importSeasons(TestData.SEASONSDATA);
		insert new ChampionshipPoints__c(Name = '1', PointsAwarded__c = 25);			
		RaceService.awardChampionshipPoints(
			new Map<Id, SObject>([select Id from Race__c]).keySet());
	}

	@isTest static void testTemporary()
	{
		// Production code path
		RaceService.calculateProvisionResults(null);
		RaceService.applyRaceResults(null);

		// Dummy code path
		PageReference dummyPage = new PageReference('/raceend');
		dummyPage.getParameters().put('dummy', 'true');
		Test.setCurrentPage(dummyPage);
		RaceService.calculateProvisionResults(new Set<Id> { 'a01b0000005lmgk' });
		RaceService.applyRaceResults(null);
	}

	@isTest static void testCSV()
	{
		SeasonService.importSeasons(TestData.SEASONSDATA);
		String csvOutput = RaceService.generateSummaryAsCSV(
			new Map<Id, SObject>([select Id from Race__c]).keySet());
		System.assertEquals('2013,Spain,,Lewis Hamilton,,\r\n', csvOutput);		
	}
}