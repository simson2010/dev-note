function FindProxyForURL(url, host)
{
    url  = url.toLowerCase();
    host = host.toLowerCase();

    if (shExpMatch(url,"*twitter*")  ||
        shExpMatch(url,"*facebook*") ||
        shExpMatch(url,"*fb*") ||
	shExpMatch(url,"*duitang.com*") ||
        shExpMatch(url,"*messenger*")) {
	        return "PROXY 192.168.1.1:8080;";
		};
	
    if (shExpMatch(url,"*youtube*") ||
        shExpMatch(url,"*google*")){
	        return "PROXY 192.168.1.2:8080;";
		};
		
    if (shExpMatch(url,"*wikipedia*") ||
        shExpMatch(url,"*blogspot*") ||
       ){
        return "PROXY 192.168.1.3:8080;";
    }
    return "DIRECT";
}
