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

	// Configure and create the DomainFactory for this Application
	public static final DomainFactory Domain = 
		new DomainFactory(
			// Map SObjectType to Domain Class Constructors 
			new Map<SObjectType, Type> {
					Team__c.SObjectType => Teams.Constructor.class,
					Race__c.SObjectType => Races.Constructor.class,
					Car__c.SObjectType => Cars.Constructor.class,
					Driver__c.SObjectType => Drivers.Constructor.class,
					Contestant__c.SObjectType => Contestants.Constructor.class }, 
			// Map SObjectType to Selector Class
			new Map<SObjectType, Type> {
					Team__c.SObjectType => TeamsSelector.class,
					Race__c.SObjectType => RacesSelector.class,
					Car__c.SObjectType => CarsSelector.class,
					Driver__c.SObjectType => DriversSelector.class,
					Contestant__c.SObjectType => ContestantsSelector.class });

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

	/**
	 * Class implements a Domain class factory
	 **/
	public class DomainFactory 
	{
		private Map<SObjectType, Type> sObjectByDomainConstructorType;
		private Map<SObjectType, Type> sObjectBySelectorType;

		public DomainFactory(
			Map<SObjectType, Type> sObjectByDomainConstructorType,
			Map<SObjectType, Type> sObjectBySelectorType)
		{
			this.sObjectByDomainConstructorType = sObjectByDomainConstructorType;
			this.sObjectBySelectorType = sObjectBySelectorType;
		}			

		/**
		 * Dynamically constructs an instance of a Domain class for the given record Ids
		 **/
		public fflib_SObjectDomain newInstance(Set<Id> recordIds)
		{
			// No point creating an empty Domain class
			if(recordIds.size()==0)
				return null;

			// Determine SObjectType and Apex classes for Domain and Selector classes
			SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSObjectType();
			Type domainConstructorClass = sObjectByDomainConstructorType.get(domainSObjectType);
			if(domainConstructorClass==null)
				throw new ApplicationException('Selector class not found for SObjectType ' + domainSObjectType);
			Type selectorClass = sObjectBySelectorType.get(domainSObjectType);
			if(domainConstructorClass==null)
				throw new ApplicationException('Domain constructor class not found for SObjectType ' + domainSObjectType);

			// Construct Selector class and query by Id for the records
			fflib_SObjectSelector selector =
				(fflib_SObjectSelector) selectorClass.newInstance();
			List<SObject> records = selector.selectSObjectsById(recordIds);

			// Construct Domain class passing in the queried records
			fflib_SObjectDomain.IConstructable domainConstructor = 
				(fflib_SObjectDomain.IConstructable) domainConstructorClass.newInstance();		
			return domainConstructor.construct(records);
		}		
	}

	public class ApplicationException extends Exception { }
}