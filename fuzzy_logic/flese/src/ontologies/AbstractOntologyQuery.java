package ontologies;

public abstract class AbstractOntologyQuery implements InterfaceOntologyQuery {

	public AbstractOntologyQuery() {
	
	}

	public abstract void query(String serviceEndPoint);
	
	public abstract String [] getResults();
	
}
