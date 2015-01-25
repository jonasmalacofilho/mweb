package mweb.tools;
#if neko
import neko.Web;
#elseif php
import php.Web;
#elseif (croxit_1)
import croxit.Web;
#end

@:forward abstract HttpRequest(HttpRequestData) from HttpRequestData
{
	@:extern inline public function new(data)
	{
		this = data;
	}

#if (neko || php || croxit_1)
	@:from inline public static function fromWeb(cls:Class<Web>):HttpRequest
	{
		// sadly we need this because of DCE
		return new NekoWebRequest();
	}
#end

	public static function fromData(method:String, uri:String, params:Map<String,Array<String>>):HttpRequest
	{
		return new HttpRequestStatic(method,uri,params);
	}

	public function withURI(uri:String)
	{
		return new HttpRequestStatic(this.getMethod(),uri,this.getParamsData());
	}
}

class HttpRequestData
{
	/**
		Should return the method (verb) used by the request - values like GET/POST
	 **/
	public function getMethod():String
	{
		return throw 'not implemented';
	}

	/**
		Should return the URI queried by the HTTP request
	 **/
	public function getUri():String
	{
		return throw 'not implemented';
	}

	/**
		Should return a String containing the parameters.
		It is advised that as a security measure on a non-GET request, only the parameters passed
		through the body of the message are sent here.
	 **/
	public function getParamsData():Map<String,Array<String>>
	{
		return throw 'not implemented';
	}

	private static function splitArgs(data:String, into:Map<String,Array<String>>)
	{
		if (data == null || data.length == 0)
			return;
		for ( part in data.split("&") )
		{
			var i = part.indexOf("=");
			var k = part.substr(0, i);
			var v = part.substr(i + 1);
			if ( v != "" )
				v = StringTools.urlDecode(v);
			var data = into[k];
			if (data == null)
			{
				into[k] = data = [];
			}
			data.push(v);
		}
	}
}

class HttpRequestStatic extends HttpRequestData
{
	var method:String;
	var uri:String;
	var params:Map<String,Array<String>>;

	public function new(method,uri,params)
	{
		this.method = method;
		this.uri = uri;
		this.params = params;
	}

	/**
		Should return the method (verb) used by the request - values like GET/POST
	 **/
	override public function getMethod():String
	{
		return method;
	}

	/**
		Should return the URI queried by the HTTP request
	 **/
	override public function getUri():String
	{
		return uri;
	}

	/**
		Should return a String containing the parameters.
		It is advised that as a security measure on a non-GET request, only the parameters passed
		through the body of the message are sent here.
	 **/
	override public function getParamsData():Map<String,Array<String>>
	{
		return params;
	}
}

#if (neko || php || croxit_1)
private class NekoWebRequest extends HttpRequestData
{
	public function new()
	{
	}

	override public function getMethod():String
	{
		return Web.getMethod();
	}

	override public function getUri():String
	{
		return Web.getURI();
	}

	override public function getParamsData():Map<String,Array<String>>
	{
		var verb = Web.getMethod();
		var args = new Map();

		switch(verb)
		{
			case "get":
				HttpRequestData.splitArgs( StringTools.replace(Web.getParamsString(), ';', '&'), args );
			case _:
				HttpRequestData.splitArgs( Web.getPostData(), args );
		}

		return args;
	}
}
#end