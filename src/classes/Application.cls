public class Application 
{
	// Configure and create the UnitOfWorkFactory for this Application
	public static final UnitOfWorkFactory UnitOfWork = 
		new UnitOfWorkFactory(
				new List<SObjectType> { 
					Driver__c.SObjectType, 
					Season__c.SObjectType, 
				  	Race__c.SObjectType, 
				  	Contestant__c.SObjectType });	

	/**
	 * Class implements a Unit of Work factory
	 **/
	public class UnitOfWorkFactory
	{
		private List<SObjectType> objectTypes;

		private UnitOfWorkFactory(List<SObjectType> objectTypes)
		{
			this.objectTypes = objectTypes;
		}

		public fflib_SObjectUnitOfWork newInstance()
		{
			return new fflib_SObjectUnitOfWork(objectTypes);
		}
	}
}