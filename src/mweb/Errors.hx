package mweb;

enum DispatcherErrorType
{
	/**
		Thrown when the URI provided doesn't satisfy all non-optional address arguments
	 **/
	MissingAddrArguments(argName:String);

	/**
		Thrown when the argument with `contents` cannot be decoded to `type`
	 **/
	InvalidArgumentType(contents:String, type:String);

	/**
		Errors not related to the user arguments
	 **/
	Internal(err:InternalError);
}

enum InternalError
{
	/**
		Thrown when a route object was expected, and either null or not a real route type was sent
	 **/
	InvalidRoute(value:Dynamic);

	/**
		Thrown when a function object was expected, and either null or not a real function type was sent
	 **/
	InvalidFunction(value:Dynamic);
}

class DispatcherError
{
	public var uriPart(default,null):String;
	public var fields(default,null):Array<String>;
	public var error(default,null):DispatcherErrorType;

	public function new(uriPart,fields,error)
	{
		this.uriPart = uriPart;
		this.fields = fields;
		this.error = error;
	}
}

enum DecoderError
{
	TypeNotFound(type:String);
	DecoderNotFound(type:String);
}

enum RequestError
{
	InvalidRequest(message:String);
	InvalidURI(uri:String,message:String);
}
