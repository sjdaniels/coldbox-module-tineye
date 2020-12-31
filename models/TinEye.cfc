component {
	processingdirective preserveCase=true;

	property name="settings" inject="coldbox:moduleSettings:tineye";	

	public any function init() {
		variables.utcBaseDate = createObject( 'java', 'java.util.Date' ).init( javacast( 'int', 0 ) );
		return this;
	}

	public numeric function getUTCTimestamp( required date dateToConvert ) {
		var asDate = parseDateTime( dateToConvert );
		return dateDiff( 's', variables.utcBaseDate, asDate );
	}

	public date function parseUTCTimestamp( required numeric utcTimestamp ) {
		var parsed_date = dateAdd( 's', arguments.utcTimestamp, variables.utcBaseDate );
		return parsed_date;
	}

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
		var nonce = createUUID();
		var date = getUTCTimestamp(now());
		var requestURL = "https://api.tineye.com/rest#arguments.path#";
		// var requestURL = "https://040d1a5e5d14110a315ec49d81381bc7.m.pipedream.net/rest#arguments.path#";

		http url="#requestURL#" method="get" result="local.cfhttp" {
			httpparam type="url" name="api_key" value="#settings.publicKey#";
			httpparam type="url" name="nonce" value="#nonce#";
			httpparam type="url" name="date" value="#date#";
			loop collection="#params#" item="local.val" index="local.key" {
				httpparam type="url" name="#local.key#" value="#urlencode(local.val)#";
			}
			httpparam type="url" name="api_sig" value="#getSignature(requestURL, date, nonce, params)#";
		}

		var result = parseResponse( local.cfhttp );
		return result;
	}
	
	private string function getSignature(required string requestURL, required numeric date, required string nonce, required struct params) {
		var signingString = "";
		// client private key +
		signingString &= settings.privateKey;
		// HTTP_VERB +
		signingString &= "GET";
		// Content-Type header +
		signingString &= "";
		// uploaded image name +
		signingString &= "";
		// date +
		signingString &= arguments.date;
		// nonce +
		signingString &= arguments.nonce;
		// request_url +
		signingString &= arguments.requestURL;
		// other query string parameters, in alpha order
		loop array="#arguments.params.keyArray().sort("text")#" item="local.key" index="local.i" {
			signingString &= (local.i gt 1 ? "&" : "") & "#local.key#=#urlEncode(arguments.params[local.key])#";
		}

		var result = hmac(signingString, settings.privateKey, "HMACSHA256").lcase();

		// echo(signingString);
		// abort;
		// dump(var=[signingString, result, signature], abort=true);

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