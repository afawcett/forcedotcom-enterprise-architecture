public class Contestants extends fflib_SObjectDomain
{
	public Contestants(List<Contestant__c> contestants) 
	{
		super(contestants);
	}

	public override void onValidate()
	{
		// Bulk load the associated races
		Set<Id> raceIds = new Set<Id>();
		for(Contestant__c contestant : (List<Contestant__c>) Records)
			raceIds.add(contestant.Race__c);
		Map<Id, Race__c> associatedRaces = 
			new Map<Id, Race__c>(new RacesSelector().selectById(raceIds));

		// Only permit new contestants to be added to Scheduled races
		for(Contestant__c contestant : (List<Contestant__c>) Records)
		{
			Race__c race = associatedRaces.get(contestant.Race__c);
			if(race.Status__c != 'Scheduled')
				contestant.addError( 'Contestants can only be added to scheduled races');
		}
	}

	/**
	 * Performs validation on update of existing Contestants
	 **/
	public override void onValidate(Map<Id,SObject> existingRecords)
	{
		// Bulk load the associated races
		Map<Id, Race__c> associatedRaces = queryAssociatedRaces();

		// Can only change drivers in scheduled races
		for(Contestant__c contestant : (List<Contestant__c>) Records)
		{			
			Race__c contestantRace = associatedRaces.get(contestant.Race__c);
			Contestant__c oldContestant  = (Contestant__c) existingRecords.get(contestant.Id);
			if(contestantRace.Status__c != 'Scheduled' && 
			   contestant.Driver__c !=  oldContestant.Driver__c)
				contestant.Driver__c.addError( 'You can only change drivers for scheduled races' );
		}
	}

	public void awardChampionshipPoints(fflib_SObjectUnitOfWork uow)
	{
		// Apply championship points to given contestants		
		for(Contestant__c contestant : (List<Contestant__c>) Records)
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

	private Map<Id, Race__c> queryAssociatedRaces()
	{
		// Bulk load the associated races
		Set<Id> raceIds = new Set<Id>();
		for(Contestant__c contestant : (List<Contestant__c>) Records)
			raceIds.add(contestant.Race__c);
		return new Map<Id, Race__c>(new RacesSelector().selectById(raceIds));		
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Contestants(sObjectList);
		}
	}	
}