public class DriversSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Driver__c.Id,
			Driver__c.Name,
			Driver__c.FIASuperLicense__c,
			Driver__c.Team__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Driver__c.sObjectType;
	}

	public List<Driver__c> selectDriversByTeam(Set<Id> teamIds)
	{
		assertIsAccessible();
		return Database.query(
			String.format('SELECT {0} FROM {1} WHERE Team__c in :teamIds ORDER BY {2}', 
			new List<String>{getFieldListString(),getSObjectName(),getOrderBy()}));
	}
}