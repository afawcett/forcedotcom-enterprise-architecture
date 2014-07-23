public class RacesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Race__c.Id,
			Race__c.Name,
			Race__c.Status__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Race__c.sObjectType;
	}

	public List<Race__c> selectById(Set<Id> raceIds)
	{
		return (List<Race__c>) selectSObjectsById(raceIds);
	}

	public List<Race__c> selectByIdWithContestants(Set<Id> raceIds)
	{
		assertIsAccessible();

		ContestantsSelector contestantSelector = new ContestantsSelector();
		contestantSelector.assertIsAccessible();

		return (List<Race__c>) Database.query(
			String.format(
					'select {0}, ' +
					  '(select {1} ' +
					     'from Contestants__r)' + 
					  'from {2} ' +
					  'where id in :raceIds ' + 
					  'order by {3}', 
				new List<String>{
					getFieldListString(),
					contestantSelector.getFieldListString(),
					getSObjectName(),
					getOrderBy()
				}));		
	}
}