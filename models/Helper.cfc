component accessors="true" singleton threadSafe {

	function init() {
		return this;
	}

	function test() {
		throw( message="It works", detail="I think it works?" );
	}

}