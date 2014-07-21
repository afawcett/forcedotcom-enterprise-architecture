public class ContestantService 
{
	public static void awardChampionshipPoints(Set<Id> contestantIds)
	{
		ApplicationUnitOfWork uow = new ApplicationUnitOfWork();

		// Apply championship points to selected contestants		
		awardChampionshipPoints(uow, new ContestantsSelector().selectById(contestantIds));

		uow.commitWork();
	}

	public static void awardChampionshipPoints(fflib_SObjectUnitOfWork uow, List<Contestant__c> contestants)
	{
		// Apply championship points to given contestants		
		for(Contestant__c contestant : contestants)
		{
			// Determine points to award for the given position
			ChampionshipPoints__c pointsForPosition = 
				ChampionshipPoints__c.getInstance(String.valueOf(contestant.RacePosition__c));
			if(pointsForPosition!=null)
			{
				// Apply points and register for udpate with uow
				contestant.ChampionshipPoints__c = pointsForPosition.PointsAwarded__c;
				uow.registerDirty(contestant);
			}
		}		
	}

	public static void retireFromRace(List<RaceRetirement> retirements)
	{
		throw new ContestantServiceException('Not implemented');
	}

	public class ContestantServiceException extends Exception {} 

	public class RaceRetirement
	{
		public Id contestantId;
		public String reason;
	}	
}