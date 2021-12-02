component {
	// Module Properties
	this.title 				= "TinEye API Module";
	this.author 			= "Sean Daniels";
	this.description 		= "Module for interacting with TinEye APIs";
	this.version			= "1.1.1+0001";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Model Namespace
	this.modelNamespace		= "tineye";
	// CF Mapping
	this.cfmapping			= "tineye";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

	function configure(){
		// module settings - stored in modules.name.settings
		settings = {
			 "privateKey":""
		};
	}
}