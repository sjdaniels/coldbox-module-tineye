component {
	processingdirective preserveCase=true;

	property name="settings" inject="coldbox:moduleSettings:tineye";	

	public struct function search(
		  required string imgURL
		, numeric limit=100
		, numeric offset=0
		, numeric backlinkLimit=100
		, string sort="score" // valid options are score, size, and crawl_date
		, string order="desc" // asc or desc
		, string domain="" // restrict search to a domain i.e. amazon.com
		, string tags="" // limit search to results tagged as valid values stock or collection 
		) {
		
		var params = [
			 image_url:arguments.imgURL
			,limit:arguments.limit
			,offset:arguments.offset
			,backlink_limit:arguments.backlinkLimit
			,sort:arguments.sort
			,order:arguments.order
		];

		if (!isempty(arguments.domain))
			params.domain = arguments.domain;

		if (!isempty(arguments.tags))
			params.tags = arguments.tags;

		return call("/search/", params);
	}

	
	public struct function imageCount() {
		return call("/image_count/");
	}

	public struct function remainingSearches() {
		return call("/remaining_searches/");
	}

	private struct function call( required string path, struct params={} ){
		var params = arguments.params;
		var requestURL = "https://api.tineye.com/rest#arguments.path#";
		// var requestURL = "https://040d1a5e5d14110a315ec49d81381bc7.m.pipedream.net/rest#arguments.path#";

		http url="#requestURL#" method="get" result="local.cfhttp" {
			httpparam type="header" name="x-api-key" value="#settings.privateKey#";
			loop collection="#params#" item="local.val" index="local.key" {
				httpparam type="url" name="#local.key#" value="#urlencode(local.val)#";
			}
		}

		var result = parseResponse( local.cfhttp );
		return result;
	}

	private any function parseResponse(required struct response) {
		var exception = { type:"TinEye" }
		
		try {
			var apiResult = deserializeJSON(arguments.response.filecontent);
		} catch (Any e) {
			exception.message = "Deserialization Error"
			exception.detail = serializeJSON(arguments.response);
			throw(argumentCollection:exception);
		}

		return apiResult;
	}
}