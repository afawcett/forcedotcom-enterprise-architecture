public class RaceService 
{
	public static Map<Id, List<ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds)
	{
		return service().calculateProvisionResults_x(raceIds);
	}

	public static void applyRaceResults(Map<Id, List<ProvisionalResult>> provisionalResultsByRaceId)
	{
		service().applyRaceResults_x(provisionalResultsByRaceId);
	}

	public static void awardChampionshipPoints(Set<Id> raceIds)
	{
		service().awardChampionshipPoints_x(raceIds);
	}

	private static IRaceService service()
	{
		if(ApexPages.currentPage()!=null)
			if(ApexPages.currentPage().getParameters().containsKey('dummy'))
				return (IRaceService) new DummyImplementation();
		return (IRaceService) new ProductionImplementation();
	}

	private interface IRaceService
	{
		Map<Id, List<ProvisionalResult>> calculateProvisionResults_x(Set<Id> raceIds);

		void applyRaceResults_x(Map<Id, List<ProvisionalResult>> provisionalResultsByRaceId);

		void awardChampionshipPoints_x(Set<Id> raceIds);
	}	

	private class DummyImplementation implements IRaceService
	{
		public Map<Id, List<ProvisionalResult>> calculateProvisionResults_x(Set<Id> raceIds)
		{
			// Dummy behaviour to allow the client to be developed 
			//    independent of the main service implementation 
			Id raceId = new List<Id>(raceIds)[0];
			ProvisionalResult hamilton = new ProvisionalResult();
			hamilton.racePosition = 1;
			hamilton.contestantName = 'Lewis Hamilton';
			hamilton.contestantId = 'a03b0000006WVph';
			ProvisionalResult rubens = new ProvisionalResult();
			rubens.racePosition = 2;
			rubens.contestantName = 'Rubens Barrichello';
			rubens.contestantId = 'a03b00000072xx9';
			return new Map<Id, List<ProvisionalResult>> {
					new List<Id>(raceIds)[0] => 
						new List<ProvisionalResult> { hamilton, rubens } };
		}

		public void applyRaceResults_x(Map<Id, List<ProvisionalResult>> provisionalResultsByRaceId)
		{
			throw new RaceServiceException('Not implemented');
		}

		public void awardChampionshipPoints_x(Set<Id> raceIds)
		{
			throw new RaceServiceException('Not implemented');
		}
	}

	private class ProductionImplementation implements IRaceService
	{
		public Map<Id, List<ProvisionalResult>> calculateProvisionResults_x(Set<Id> raceIds)
		{			
			return null;
		}

		public void applyRaceResults_x(Map<Id, List<ProvisionalResult>> provisionalResultsByRaceId)
		{
			ApplicationUnitOfWork uow = new ApplicationUnitOfWork();
			uow.commitWork();
		}

		public void awardChampionshipPoints_x(Set<Id> raceIds)
		{
			ApplicationUnitOfWork uow = new ApplicationUnitOfWork();

			// Query Races and contestants and bulkify list of all contestants
			List<Contestant__c> contestants = new List<Contestant__c>();
			for(Race__c race : new RacesSelector().selectByIdWithContestants(raceIds))
				contestants.addAll(race.Contestants__r);

			// Delegate to Contestant Domain class
			new Contestants(contestants).awardChampionshipPoints(uow);

			// Commit work
			uow.commitWork();
		}
	}

	public class RaceServiceException extends Exception {} 	

	public class ProvisionalResult
	{
		public Integer racePosition {get; set;}
		public Id contestantId {get; set;}
		public String contestantName {get; private set;}		
	}
}