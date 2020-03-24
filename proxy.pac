function FindProxyForURL(url, host)
{
    url  = url.toLowerCase();
    host = host.toLowerCase();

    if (shExpMatch(url,"*duitang.com*") 
       
       ) {
	  return "PROXY 192.168.1.1:8080";
      };
	
    return "DIRECT";
}
